{ hmConfig, pkgs }:
{
  home-manager.users."${hmConfig.username}" = {
    programs.git = {
      enable = true;
      userName = "Jonathan Helfer";
      userEmail = "j.helfer@navax.com";
      extraConfig = {
        init.defaultBranch = "main";
        credential = {
          helper = "${pkgs.git-credential-manager}/bin/git-credential-manager";
          credentialStore = "secretservice";

          "https://dev.azure.com" = {
            useHttpPath = true;
          };
        };
      };
    };
  };
}
