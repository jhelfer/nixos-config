{ hmConfig, pkgs }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.git = {
      enable = true;
      userName = "Jonathan Helfer";
      userEmail = "j.helfer@navax.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        merge = {
          ff = false;
          commit = false;
        };
        credential = {
          helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
          credentialStore = "secretservice";

          "https://dev.azure.com" = {
            useHttpPath = true;
          };
        };
      };
    };

    home.persistence."${hmConfig.persistDir}".directories = [ ".local/share/keyrings" ];
  };

  services.gnome.gnome-keyring.enable = true;
}
