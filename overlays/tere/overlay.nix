inputs: self: super: {
  tere = (self.runCommand "tere-wrapped"
    {
      buildInputs = [ self.makeWrapper ];
    }
    ''
      makeWrapper ${super.tere}/bin/tere $out/bin/tere --add-flags "--skip-first-run-prompt"
    ''
  );
}
