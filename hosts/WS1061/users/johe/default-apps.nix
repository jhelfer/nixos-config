username: {
  home-manager.users.${username} = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
      };
    };

    home.sessionVariables = {
      BROWSER = "zen-beta";
      VISUAL = "zeditor";
    };
  };
}
