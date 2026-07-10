let
  username = "johe";
in
{
  imports = [
    (import ./programs/foot.nix username)
    (import ./programs/git.nix username)
    (import ./programs/zed-editor.nix username)
    (import ./programs/zen-browser.nix username)
    (import ./shell.nix username)
    (import ./window-managers/niri.nix username)
  ];

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  home-manager.users.${username} = {
    home.stateVersion = "26.11";
  };

  ephemeral.directories = [
    "/home/${username}/.ssh"
    "/home/${username}/Projects"
  ];
}
