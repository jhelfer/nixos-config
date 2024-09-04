{ hmConfig }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.zsh = {
      enable = true;
      history.path = "${hmConfig.homeDirectory}/.local/state/zsh/history";
      initExtra = ''
        rebuild() { sudo nixos-rebuild ''${1:=test} --flake "$HOME/nixos-config" }
      '';
    };

    home.persistence."${hmConfig.persistDir}".directories = [ ".local/state/zsh" ];
  };
}
