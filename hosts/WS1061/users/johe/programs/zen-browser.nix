username: { inputs, ... }: {
  home-manager.users.${username} = {
    imports = [ inputs.zen-browser.homeModules.beta ];

    programs.zen-browser.enable = true;
  };

  ephemeral.directories = [ "/home/${username}/.config/zen" ];
}
