{ config, lib, ... }: {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  ephemeral.directories = lib.mapAttrsToList (user: _: "/home/${user}/.local/state/wireplumber") (
    lib.filterAttrs (_: u: u.isNormalUser) config.users.users
  );
}
