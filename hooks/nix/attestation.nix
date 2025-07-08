{
  pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/4fe8d07066f6ea82cda2b0c9ae7aee59b2d241b3.tar.gz";
    sha256 = "sha256:06jzngg5jm1f81sc4xfskvvgjy5bblz51xpl788mnps1wrkykfhp";
  }) {}
}:

with pkgs;

let
  packages = rec {

    # The derivation for chord
    kubectx = stdenv.mkDerivation rec {
      pname = "chord";
      version = "0.0.in-tuto";
      src = fetchgit {
        url = "https://gitlab.inria.fr/nix-tutorial/chord-tuto-nix-2022";
        rev = "069d2a5bfa4c4024063c25551d5201aeaf921cb3";
        sha256 = "sha256-MlqJOoMSRuYeG+jl8DFgcNnpEyeRgDCK2JlN9pOqBWA=";
      };

      buildInputs = [
        pkgconfig
        cosign          # A tool for generating and verifying Sigstore signatures
        patatt          # Send attestations over email for patches
        tpm-quote-tools # A collection of programs that provide support for TPM based attestation using the TPM quote mechanism
        tpm2-totp       # Attest the trustworthiness of a device against a human using time-based one-time passwords
        witness         # A tool for generating and verifying in-toto attestations
      ];

    };

    kubectx-docker = dockerTools.buildImage {
      name = "chord-docker";
      tag = "tuto-nix";
      contents = [ chord ];
      config = {
        Cmd = [ "${chord}/bin/chord" ];
        WorkingDir = "/data";
        Volumes = { "/data" = { }; };
      };
    };

    # The shell of our experiment runtime environment
    expEnv = mkShell rec {
      name = "exp01Env";
      buildInputs = [
        chord
      ];
    };

  };
in
  packages
