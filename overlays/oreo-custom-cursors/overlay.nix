inputs: self: super:

{
  oreo-custom-cursors = super.oreo-cursors-plus.override {
    cursorsConf = ''
      custom = color: #1c1c1c, stroke: #eeeeee, stroke-width: 2, stroke-opacity: 1
      sizes = 24
    '';
  };
}
