{ config, inputs, ... }: {
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoGenerateKeys.enable = true;
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
  };

  ephemeral.directories = [
    config.boot.lanzaboote.pkiBundle
    "/var/lib/auto-cryptenroll"
  ];
}
