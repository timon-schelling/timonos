# streamer-0

Raspberry Pi Zero WH + InnoMaker DAC Mini HAT.
AirPlay and Spotify Connect, reachable over Tailscale. armv6l cross compiled from x86_64.

```
nix build .#nixosConfigurations.streamer-0.config.system.build.sdImage
zstd -d --stdout result/sd-image/*.img.zst | sudo dd of=/dev/sdX bs=4M status=progress conv=fsync
```

In `config/` on the `FIRMWARE` partition `wifi/<SSID>.psk`, `tailscale-authkey`, optionally `hostname`.

Update:

```
nixos-rebuild switch --flake .#streamer-0 --target-host user@streamer-0 --elevate=sudo --ask-elevate-password
```
