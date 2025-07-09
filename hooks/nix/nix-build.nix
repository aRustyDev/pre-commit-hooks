{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenv.mkDerivation {
  pname = "pre-commit-hooks-nix-build";
  version = "0.1.0";
  src = ./.;
  buildPhase = ''
    echo "Running nix build validation..."
  '';
  installPhase = ''
    mkdir -p $out
    echo "Nix build validation completed" > $out/result.txt
  '';
}
