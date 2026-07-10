username: {
  home-manager.users.${username} = {
    programs.zed-editor.enable = true;
  };

  ephemeral.directories = [ "/home/${username}/.local/share/zed" ];
}
