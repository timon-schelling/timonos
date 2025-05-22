inputs: self: super:
let
  writeNu = name: script: f:
    f "${name}" ''
      #!${self.nushell}/bin/nu --stdin

      ${script}
    '';
  writeScript = name: script: writeNu name script self.writeScript;
  writeScriptBin = name: script: writeNu name script self.writeScriptBin;

  envJsonFromDrv = drv:
    let
      scrubbed = (builtins.removeAttrs drv.drvAttrs [
        "allowedReferences"
        "allowedRequisites"
        "disallowedReferences"
        "disallowedRequisites"
      ]);
      outputs' = builtins.map (n: {
        name = n;
        value = builtins.placeholder n;
      }) (scrubbed.outputs or [ "out" ]);
      outputs = builtins.listToAttrs outputs';
      json = derivation (scrubbed // { args = [ ./get-env.sh ]; } // outputs);
    in
    (self.runCommand "${drv.name}-env.json" {} ''
      ln -s ${json} $out
    '');
  envFromDrv = drv:
    {
      name ? drv.name,
      pathLike ? [ ],
      pathLikeDefaults ? true,
      ignore ? [ ],
      ignoreDefaults ? true,
      preEnvLoadCommands ? "",
      postEnvLoadCommands ? "",
    }:
    let
      env = envJsonFromDrv drv;
      pathLike' = pathLike ++ (if pathLikeDefaults then [
        "PATH"
        "LD_LIBRARY_PATH"
        "XDG_DATA_DIRS"
        "XDG_CONFIG_DIRS"
      ] else []);
      ignore' = ignore ++ (if ignoreDefaults then [
        "HOME"
        "USER"
        "SHELL"
        "TERM"
      ] else []);
    in
    (self.writeScript name ''
      let path_like_conversion = {
          from_string: { |s| $s | split row (char esep) | path expand -n }
          to_string: { |v| $v | path expand -n | str join (char esep) }
      }

      $env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
      ${self.lib.concatStrings (self.lib.lists.map (x: ''
        ${x}: $path_like_conversion,
      '') pathLike')}
      }

      let variables = open ${env}
          | get variables
          | transpose key val
          | update val { if "value" in $in { $in.value } else { "" }}
          | each { { $in.key : $in.val } } | into record

      mut variables = $variables

      ${self.lib.concatStrings (self.lib.lists.map (x: ''
        try { $variables = $variables | reject ${x} }
      '') ignore')}

      ${self.lib.concatStrings (self.lib.lists.map (x: ''
        try { $variables = $variables | update ${x} { $in | split row ":" | append $env.${x} } }
      '') pathLike')}

      ${preEnvLoadCommands}

      load-env $variables

      ${postEnvLoadCommands}
    '');
    shellBinFromDrv = drv: args:
      (let
        env = envFromDrv drv args;
      in
      writeScriptBin env.name ''
        exec ${self.nushell}/bin/nu -e "source ${env}"
      '');

  nu = {
    inherit writeScript;
    inherit writeScriptBin;

    inherit envFromDrv;
    inherit shellBinFromDrv;
  };
in { inherit nu; }
