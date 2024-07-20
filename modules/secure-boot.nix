{ config, inputs, pkgs, ... }: {
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = config.extra.pkiBundle;
    };
    loader.efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = [ pkgs.sbctl ];

  environment.persistence."${config.extra.persistDir}" = {
    directories = [ "${config.extra.pkiBundle}" ];
  };
}
