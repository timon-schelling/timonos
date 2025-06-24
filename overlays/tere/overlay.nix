inputs: self: super: {
  tere = (self.runCommand "tere-wrapped"
    {
      buildInputs = [ self.makeWrapper ];
    }
    ''
      makeWrapper ${self.lib.getExe super.tere} $out/bin/tere --add-flags "--skip-first-run-prompt"
    ''
  );
}
