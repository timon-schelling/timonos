# homelab-0

## testet new install methodology

```
ssh nixos@192.168.178.93
nix-shell -p disko
sudo disko --mode disko --flake github:timon-schelling/timonos/dev-homelab-0#homelab-0
```

ensure that the created swap partition is mounted

```
sudo systemd-machine-id-setup --root=/mnt
sudo nixos-install --no-root-passwd --flake github:timon-schelling/timonos/dev-homelab-0#homelab-0
```
