{ pkgs, config, ... }:
{
  home-manager.users."${config.extra.username}" = {
    programs.zsh = {
      enable = true;
      history.path = "${config.extra.homeManager.home.homeDirectory}/.local/state/zsh/history";
      initExtra = ''
        rebuild() { sudo nixos-rebuild ''${1:=test} --flake "/persist/etc/nixos-config" }
      '';
    };

    home.persistence."${config.extra.homePersistDir}".directories = [ ".local/state/zsh" ];
  };
}
