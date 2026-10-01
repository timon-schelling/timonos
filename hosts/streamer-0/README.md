# streamer-0

Raspberry Pi Zero WH + InnoMaker DAC Mini HAT.
Spotify Connect and AirPlay, reachable over Tailscale. armv6l, so everything is cross compiled from x86_64.

```
nix build .#nixosConfigurations.streamer-0.config.system.build.sdImage
zstd -d --stdout result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

Put `tailscale-authkey` and `wifi/<SSID>.psk` on the `FIRMWARE` partition before the first boot.

Update:

```
NIX_SSHOPTS=-t nixos-rebuild switch --flake .#streamer-0 --target-host user@streamer-0 --use-remote-sudo
```
