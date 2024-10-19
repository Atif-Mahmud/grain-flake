{
  description = "A minimal flake for grain compiler.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Adjust if you're targeting a different system
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.grain = pkgs.stdenv.mkDerivation rec {
        pname = "grain";
        version = "preview";
        # version = "grain-v0.6.6";

        dontUnpack = true;

        buildInputs = with pkgs; [
          stdenv.cc.cc
          openssl
          libgcc
          glibc
        ];

        nativeBuildInputs = [ pkgs.autoPatchelfHook ];

        src = pkgs.fetchurl {
          url = "https://github.com/grain-lang/grain/releases/download/${version}/grain-linux-x64";
          hash = "sha256-1EuST46GYjgcq891guoIlOXJpVSAr6tx0xem+NUq4o8=";
        };

        installPhase = ''
          mkdir -p $out/bin
          cp $src $out/bin/grain
          chmod +x $out/bin/grain
        '';

        postFixup = ''
          patchelf \
            --set-rpath ${pkgs.lib.makeLibraryPath [ pkgs.openssl pkgs.libgcc pkgs.glibc ]} \
            $out/bin/grain
        '';

        meta = {
          description = "Grain compiler application";
          license = pkgs.lib.licenses.unfreeRedistributable;
        };
      };
    };
}
