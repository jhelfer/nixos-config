{ hmConfig, pkgs }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.vscode = {
      enable = true;
      userSettings = {
        "diffEditor.experimental.showMoves" = true;
        "diffEditor.hideUnchangedRegions.enabled" = true;
        "diffEditor.ignoreTrimWhitespace" = false;
        "git.autofetch" = true;
        "window.titleBarStyle" = "custom";
      };
      extensions = with pkgs.vscode-extensions; [
        eamodio.gitlens
        jnoortheen.nix-ide
        svelte.svelte-vscode
      ];
    };
  };
}
