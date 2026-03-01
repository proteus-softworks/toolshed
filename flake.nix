{
  inputs = {
    nixpkgs-25_11.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs-25_11, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs-25_11.legacyPackages.${system};

        # Overrides
        elixir = pkgs.elixir_1_19;
        elixir-ls = pkgs.elixir-ls.override {
          elixir = pkgs.elixir_1_19;
        };

        coreDeps = [
          elixir
          elixir-ls
          pkgs.cacert
        ];

        appRuntimeDeps = [
          pkgs.ffmpeg-headless
          pkgs.imagemagick
        ];

        buildDeps = [
          pkgs.nodejs
          pkgs.git
          pkgs.go-task
          pkgs.nixpkgs-fmt
        ];

        runtimeUtils = [
          pkgs.bashInteractive
          pkgs.coreutils
          pkgs.gawk
          pkgs.gnugrep
          pkgs.gnused
          pkgs.findutils
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = coreDeps ++ appRuntimeDeps ++ buildDeps ++ (with pkgs; [
            (writeShellScriptBin "build-release" ''
              set -e
              mix local.hex --force
              mix local.rebar --force
              export MIX_ENV=PROD
              mix deps.get --only prod
              mix deps.compile
              mix compile
              mix assets.deploy
              mix release
            '')

            (writeShellScriptBin "build-docker" ''
              set -e
              nix build .#dockerImage
              docker load < result
            '')
          ]);
        };

        shellHook = ''
          export MIX_HOME=$PWD/.nix-mix
          export HEX_HOME=$PWD/.nix-hex
          export PATH=$MIX_HOME/bin:$HEX_HOME/bin:$PATH
        '';

        packages.dockerImage = pkgs.dockerTools.buildLayeredImage {
          name = "toolshed";
          tag = "latest";
          contents = appRuntimeDeps ++ runtimeUtils;

          config = {
            WorkingDir = "/app";
            Env = [
              "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
              "LANG=C.UTF-8"
              "LC_ALL=C.UTF-8"
            ];
            Cmd = [ "/app/bin/server" ];
          };
        };
      });
}
