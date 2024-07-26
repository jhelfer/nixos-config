Follow the steps under "Manual Installation" until a network connection is established (at least run `sudo -i`).
https://nixos.org/manual/nixos/stable/#sec-installation-manual

```
nix-shell -p git
git clone https://github.com/jhelfer/nixos-config.git /tmp/nixos-config
nix --experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko --flake /tmp/nixos-config#WS1061
mkdir /mnt/persist/passwords
mkpasswd -m sha-512 > /mnt/persist/passwords/johe
nixos-install --flake /tmp/nixos-config#WS1061
```

Setup VPN (OpenConnect - FortiVPN)

```
nix-shell -p networkmanagerapplet
nm-connection-editor
```
