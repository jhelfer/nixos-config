{
  config,
  inputs,
  lib,
  ...
}:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  boot.initrd.systemd = {
    enable = true;
    services.rollback = {
      description = "Rollback btrfs root subvolume to initial state";
      wantedBy = [ "initrd.target" ];
      after = [ "systemd-cryptsetup@${config.extra.luksDevice}.service" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir /mnt

        # We first mount the btrfs root to /mnt
        # so we can manipulate btrfs subvolumes.
        mount -o subvol=/ /dev/mapper/${config.extra.luksDevice} /mnt

        # While we're tempted to just delete /root and create
        # a new snapshot from /root-blank, /root is already
        # populated at this point with a number of subvolumes,
        # which makes `btrfs subvolume delete` fail.
        # So, we remove them first.
        btrfs subvolume list -o /mnt/root |
        cut -f 9 -d ' ' |
        while read subvolume; do
          echo "deleting /$subvolume subvolume..."
          btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "deleting /root subvolume..." &&
        btrfs subvolume delete /mnt/root

        echo "restoring blank /root subvolume..."
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        # Once we're done rolling back to a blank snapshot,
        # we can unmount /mnt and continue on the boot process.
        umount /mnt
      '';
    };
  };

  environment.persistence."${config.extra.persistDir}" = {
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/log"
    ];
    files = [ "/etc/machine-id" ];
  };

  programs.fuse.userAllowOther = true;

  system.activationScripts.persistent-dirs.text =
    let
      mkHomePersist =
        user:
        lib.optionalString user.createHome ''
          mkdir -p ${config.extra.persistDir}/${user.home}
          chown ${user.name}:${user.group} ${config.extra.persistDir}/${user.home}
          chmod ${user.homeMode} ${config.extra.persistDir}/${user.home}
        '';
      users = lib.attrValues config.users.users;
    in
    lib.concatLines (map mkHomePersist users);
}
