# InnoMaker DAC Mini HAT, pcm5122 on i2s, control over i2c at 0x4d.
{ ... }:

{
  boot.kernelPatches = [
    {
      name = "pcm512x-gpio-outputs";
      patch = ./pcm512x-gpio-outputs.patch;
    }
  ];

  hardware.deviceTree.overlays = [
    {
      name = "innomaker-dac-mini-pcm5122";
      dtsText = ''
        /dts-v1/;
        /plugin/;

        / {
          compatible = "brcm,bcm2835", "brcm,bcm2837";
        };

        &i2s {
          #sound-dai-cells = <0>;
          pinctrl-names = "default";
          pinctrl-0 = <&pcm_gpio18>;
          status = "okay";
        };

        &i2c1 {
          #address-cells = <1>;
          #size-cells = <0>;
          status = "okay";

          pcm5122: dac@4d {
            compatible = "ti,pcm5122";
            reg = <0x4d>;
            #sound-dai-cells = <0>;
            clocks = <&dac_osc44>;
            ti,gpio-output-high = <6>;
            ti,gpio-output-low = <3>;
            status = "okay";
          };
        };

        &gpio {
          dac_unmute: dac-unmute-hog {
            gpio-hog;
            gpios = <6 0>;
            output-high;
            line-name = "dac-unmute";
          };
        };

        &{/} {
          dac_osc44: dac-osc44 {
            compatible = "fixed-clock";
            #clock-cells = <0>;
            clock-frequency = <45158400>;
            clock-output-names = "dac-osc44";
          };

          sound {
            compatible = "simple-audio-card";
            simple-audio-card,name = "InnoMaker DAC";
            simple-audio-card,format = "i2s";
            simple-audio-card,bitclock-master = <&dac_codec>;
            simple-audio-card,frame-master = <&dac_codec>;
            status = "okay";

            simple-audio-card,cpu {
              sound-dai = <&i2s>;
            };

            dac_codec: simple-audio-card,codec {
              sound-dai = <&pcm5122>;
            };
          };
        };
      '';
    }
  ];
}
