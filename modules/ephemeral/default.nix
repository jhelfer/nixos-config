{
  config,
  lib,
  pkgs,
  utils,
  ...
}:
let
  cfg = config.ephemeral;

  normalizePath = p: if p == "/" then "/" else lib.removeSuffix "/" p;

  mountSet = lib.genAttrs (lib.attrNames config.fileSystems) (_: true);
  subvolMounts = lib.mapAttrs' (n: m: lib.nameValuePair (normalizePath m) n) cfg.resetSubvolumes;

  # Find the reset subvolume for a path, or null if under another mount
  findResetSubvol =
    path: isFile:
    let
      climb = p: subvolMounts.${p} or (if mountSet ? ${p} || p == "/" then null else climb (dirOf p));
    in
    climb (normalizePath (if isFile then dirOf path else path));

  mkCoverageWarnings =
    type: isFile:
    map (p: "'${p}' in ephemeral.${type} is not covered by any resetSubvolumes mount point") (
      lib.filter (p: findResetSubvol p isFile == null) cfg.${type}
    );

  pathDepth = p: lib.count (part: part != "") (lib.splitString "/" (normalizePath p));

  # Ensure parent paths are processed before nested paths (e.g. /var/log before /var/log/journal)
  sortedDirectories = lib.sort (a: b: pathDepth a < pathDepth b) cfg.directories;

  groupBySubvol =
    isFile: paths:
    lib.genAttrs (lib.attrNames cfg.resetSubvolumes) (
      name: lib.filter (p: findResetSubvol p isFile == name) paths
    );

  # Map directories to their escaped persist subvolume names
  persistNames = lib.genAttrs sortedDirectories (dir: utils.escapeSystemdPath dir);

  toBashArray =
    name: val:
    if lib.isAttrs val then
      let
        toValue = v: if lib.isList v then lib.concatLines v else v;
        toEntry = k: v: "[${lib.escapeShellArg k}]=${lib.escapeShellArg (toValue v)}";
      in
      "declare -A ${name}=(${lib.concatMapAttrsStringSep " " toEntry val})"
    else
      "${name}=(${lib.concatMapStringsSep " " lib.escapeShellArg val})";

  mkScript =
    {
      name,
      vars,
      file,
      runtimeInputs ? [ ],
    }:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = ''
        BTRFS_DEVICE=${lib.escapeShellArg cfg.device}
        ${vars}
        ${builtins.readFile file}
      '';
    };

  prepareScript = mkScript {
    name = "ephemeral-prepare";
    vars = ''
      ${toBashArray "subvol_mounts" cfg.resetSubvolumes}
      ${toBashArray "directories" (groupBySubvol false sortedDirectories)}
      ${toBashArray "files" (groupBySubvol true cfg.files)}
      ${toBashArray "persist_names" persistNames}
    '';
    file = ./scripts/prepare.sh;
  };

  mountScript = mkScript {
    name = "ephemeral-mount";
    vars = toBashArray "persist_names" persistNames;
    file = ./scripts/mount.sh;
  };

  orphanScript = mkScript {
    name = "ephemeral-orphans";
    runtimeInputs = with pkgs; [
      btrfs-progs
      coreutils
      gawk
      util-linux
    ];
    vars = toBashArray "expected_names" (lib.attrValues persistNames);
    file = ./scripts/orphans.sh;
  };

  mkService =
    {
      description,
      wantedBy,
      after,
      before,
      script,
    }:
    {
      inherit
        description
        wantedBy
        after
        before
        ;
      unitConfig.DefaultDependencies = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = script;
      };
    };
in
{
  options.ephemeral = {
    enable = lib.mkEnableOption "";

    device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/mapper/cryptroot";
    };

    resetSubvolumes = lib.mkOption {
      type = lib.types.attrsOf lib.types.externalPath;
      example = {
        "@root" = "/";
      };
    };

    directories = lib.mkOption {
      type = lib.types.listOf lib.types.externalPath;
      default = [ ];
    };

    files = lib.mkOption {
      type = lib.types.listOf lib.types.externalPath;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    warnings = mkCoverageWarnings "directories" false ++ mkCoverageWarnings "files" true;

    environment.systemPackages = [ orphanScript ];

    system.activationScripts.ephemeral-check.text = "${lib.getExe orphanScript} check";

    # Static mount units for shutdown ordering - systemd will track mounts
    # done by the initrd script and properly order service stops
    systemd.mounts = map (dir: {
      what = cfg.device;
      where = dir;
      type = "btrfs";
      options = "subvol=@persist/${utils.escapeSystemdPath dir}";
      unitConfig.ConditionPathIsMountPoint = dir;
    }) sortedDirectories;

    boot.initrd.systemd = {
      storePaths = [
        (lib.getExe prepareScript)
        (lib.getExe mountScript)
      ];

      extraBin = {
        btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
        chmod = "${pkgs.coreutils}/bin/chmod";
        chown = "${pkgs.coreutils}/bin/chown";
        cp = "${pkgs.coreutils}/bin/cp";
        dirname = "${pkgs.coreutils}/bin/dirname";
        findmnt = "${pkgs.util-linux}/bin/findmnt";
        mkdir = "${pkgs.coreutils}/bin/mkdir";
        mv = "${pkgs.coreutils}/bin/mv";
      };

      services = {
        ephemeral-prepare = mkService {
          description = "Prepare ephemeral btrfs subvolumes";
          wantedBy = [ "initrd.target" ];
          after = [ "cryptsetup.target" ];
          before = [ "sysroot.mount" ];
          script = lib.getExe prepareScript;
        };

        ephemeral-mount = mkService {
          description = "Mount persistent directories";
          wantedBy = [ "initrd-fs.target" ];
          after = [ "sysroot.mount" ];
          before = [ "initrd-fs.target" ];
          script = lib.getExe mountScript;
        };
      };
    };
  };
}
