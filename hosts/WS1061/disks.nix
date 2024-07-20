{
  inputs,
  luksDevice,
  persistDir,
  config,
  ...
}:
{
  imports = [ inputs.disko.nixosModules.disko ];

  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "${config.extra.luksDevice}";
                settings = {
                  allowDiscards = true;
                };
                content = {
                  type = "btrfs";
                  extraArgs = [ "-f" ];
                  postCreateHook = ''
                    mount -o subvol=/ /dev/mapper/${config.extra.luksDevice} /mnt
                    btrfs subvolume snapshot -r /mnt/root /mnt/root-blank
                    umount /mnt
                  '';
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "${config.extra.persistDir}" = {
                      mountpoint = "${config.extra.persistDir}";
                      mountOptions = [
                        "compress=zstd"
                        "noatime"
                      ];
                    };
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "32G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."${config.extra.persistDir}".neededForBoot = true;
}
