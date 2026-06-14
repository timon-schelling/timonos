{ pkgs, ... }:

{
  services.avahi.enable = true;

  services.pipewire = {
    extraConfig.pipewire."10-raop-discover"."context.modules" = [
      { name = "libpipewire-module-raop-discover"; }
    ];
    raopOpenFirewall = true;
  };
}
