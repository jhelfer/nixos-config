{
  inputs,
  osConfig,
  pkgs,
  ...
}:
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot = {
    lanzaboote = {
      enable = true;
      pkiBundle = osConfig.pkiBundle;
    };
    loader.efi.canTouchEfiVariables = true;
  };

  environment.systemPackages = [ pkgs.sbctl ];

  environment.persistence."${osConfig.persistDir}" = {
    directories = [ "${osConfig.pkiBundle}" ];
  };
}
