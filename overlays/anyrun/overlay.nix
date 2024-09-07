inputs: self: super: {
  anyrun-plugins = inputs.anyrun.packages.${super.system};
}
