# nix run .#nixosConfigurations.streamer-0.config.system.build.vm
{ config, pkgs, ... }:

let
  dtb = pkgs.pkgsBuildBuild.runCommand "streamer-0-vm.dtb" { nativeBuildInputs = [ pkgs.pkgsBuildBuild.dtc ]; } ''
    dtc -q -I dtb -O dts ${config.hardware.deviceTree.package}/${config.hardware.deviceTree.name} \
      | sed '/compatible = "brcm,bcm2835-pm", "brcm,bcm2835-pm-wdt";/a status = "disabled";' \
      | dtc -q -I dts -O dtb -o $out
  '';
in
{
  system.build.vm = pkgs.pkgsBuildBuild.writeShellApplication {
    name = "streamer-0-vm";
    runtimeInputs = with pkgs.pkgsBuildBuild; [
      qemu
      zstd
    ];
    text = ''
      img="''${1:-streamer-0-vm.img}"
      if [ "$(cat "$img.src" 2>/dev/null)" != "${config.system.build.sdImage}" ]; then
        zstd -d --stdout ${config.system.build.sdImage}/sd-image/*.img.zst > "$img"
        qemu-img resize -f raw "$img" 4G
        echo "${config.system.build.sdImage}" > "$img.src"
      fi
      exec qemu-system-arm -M raspi0 \
        -kernel ${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile} \
        -initrd ${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile} \
        -dtb ${dtb} \
        -append "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}" \
        -drive file="$img",format=raw,if=sd \
        -serial null -serial stdio -display none \
        -netdev user,id=net0,hostfwd=tcp::2222-:22 -device usb-net,netdev=net0 \
        -audiodev pipewire,id=snd0 -device usb-audio,audiodev=snd0
    '';
  };
}
