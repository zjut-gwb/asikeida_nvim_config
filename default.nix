{
  lib,
  stdenvNoCC,
  languages ? [],
  extraLanguages ? [],
}: let
  inherit (stdenvNoCC) mkDerivation;
  inherit (lib) cleanSource concatStringsSep;
in
  mkDerivation {
    pname = "lingshin-nvim-config";
    version = "0.4";
    src = cleanSource ./.;

    installPhase = let
      langs = "$out/langs";
    in ''
      mkdir -p $out
      cp -r $src/* $out
      rm -rf ${langs}

      if test -n "${toString languages}"
      then
        mkdir -p ${langs}
        for lang in ${concatStringsSep " " languages}
        do
          ln -s ../template/langs/$lang.lua ${langs}/$lang.lua
        done
      fi

      if test -n "${toString extraLanguages}"
      then
        mkdir -p ${langs}
        for lang in ${toString extraLanguages}
        do
          cp "$lang" ${langs}/
        done
      fi
    '';
  }
