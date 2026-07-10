username: {
  home-manager.users.${username} = {
    programs.git = {
      enable = true;
      settings = {
        init.defaultBranch = "main";
        user = {
          name = "Jonathan Helfer";
          email = "j.helfer@navax.com";
        };
      };
    };
  };
}
