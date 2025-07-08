{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "test-package";
  version = "1.0.0";

  src = ./.;

  buildPhase = ''
    echo "Building test package"
  '';

  installPhase = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/test
    echo "echo 'Hello from test package'" >> $out/bin/test
    chmod +x $out/bin/test
  '';
}
