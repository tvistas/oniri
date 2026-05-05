{
  description = "oniri — automatically maximizes the only window of a niri workspace";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.rustPlatform.buildRustPackage {
            pname = "oniri";
            version = "1.2.0";
            src = ./.;
            cargoLock.lockFile = ./Cargo.lock;
            nativeBuildInputs = [ pkgs.scdoc ];
            postBuild = ''
              scdoc < doc/man/oniri.1.scd > doc/man/oniri.1
            '';
            postInstall = ''
              install -Dm644 doc/man/oniri.1 "$out/share/man/man1/oniri.1"
              install -Dm644 res/completions/oniri.bash "$out/share/bash-completion/completions/oniri"
              install -Dm644 res/completions/oniri.zsh  "$out/share/zsh/site-functions/_oniri"
              install -Dm644 res/completions/oniri.fish "$out/share/fish/vendor_completions.d/oniri.fish"
            '';
            meta = with pkgs.lib; {
              description = "Automatically maximizes the only window of a niri workspace";
              homepage = "https://github.com/Antiz96/oniri";
              license = licenses.gpl3Plus;
              mainProgram = "oniri";
              platforms = platforms.linux;
            };
          };
        }
      );

      overlays.default = final: _prev: {
        oniri = self.packages.${final.stdenv.hostPlatform.system}.default;
      };
    };
}
