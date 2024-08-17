inputs: self: super:
let
  writeNu = name: script: f: f "${name}" ''
    #!${self.nushell}/bin/nu --stdin

    ${script}
  '';
  nu = {
    writeScript = name: script: writeNu name script self.writeScript;
    writeScriptBin = name: script: writeNu name script self.writeScriptBin;
  };
in
{
  inherit nu;
}
