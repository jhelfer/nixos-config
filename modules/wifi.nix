{
  networking.wireless.iwd = {
    enable = true;
    settings = {
      Settings.AutoConnect = true;
    };
  };

  ephemeral.directories = [ "/var/lib/iwd" ];
}
