inputs: self: super:

{
  # Temporary fix, remove when https://github.com/NixOS/nixpkgs/issues/483540 is closed.
  # Completely disables the `shaderc` feature that was broken by https://github.com/NixOS/nixpkgs/pull/477464.
  ffmpeg-full = super.ffmpeg-full.override { withShaderc = false; };
}
