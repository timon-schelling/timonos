args:

let
  imports = import ./imports.nix args;
  merge = import ./merge.nix args;
in
{
  inherit imports;

  inherit (merge) merge;

  trace = t: builtins.trace t t;
  traceJSON = t: builtins.trace (builtins.toJSON t) t;
}
