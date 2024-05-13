{
  inputs = {
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    flake-utils.follows = "nix-vscode-extensions/flake-utils";
    # nixpkgs.follows = "nix-vscode-extensions/nixpkgs";
    nixpkgs.url = "nixpkgs/nixos-unstable";
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let

        # pkgs = inputs.nixpkgs.legacyPackages.${system};
        pkgs = import inputs.nixpkgs { inherit system; config.allowUnfree = true; }; 
        extensions = inputs.nix-vscode-extensions.extensions.${system};
        inherit (pkgs) vscode-with-extensions vscodium;

        packages.default = pkgs.vscode-with-extensions.override {
          vscodeExtensions = with pkgs.vscode-extensions; [
            # Essentials
            mikestead.dotenv
            editorconfig.editorconfig
            vscodevim.vim
            dracula-theme.theme-dracula

            # Interface Improvements
            eamodio.gitlens
            usernamehw.errorlens

            # Nix
            jnoortheen.nix-ide
            arrterian.nix-env-selector

            # Bash
            mads-hartmann.bash-ide-vscode

            # Testing
            ms-vscode.test-adapter-converter
            
            ms-dotnettools.csdevkit
            ms-dotnettools.csharp
            #extensions.vscode-marketplace.ms-dotnettools.csharp
          ] ++ [
            # csharp
            extensions.vscode-marketplace.ms-dotnettools.vscode-dotnet-runtime
          ];
        };

        # Add dependencies that are only needed for development
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            dotnetCorePackages.sdk_8_0
            packages.default
          ];

          shellHook = ''
             export DOTNET_CLI_TELEMETRY_OPTOUT=1
             export DOTNET_NOLOGO=1
             export DOTNET_BIN=${pkgs.dotnetCorePackages.sdk_8_0}/bin/dotnet
             export DOTNET_ROOT=${pkgs.dotnetCorePackages.sdk_8_0}
             export PATH=$PATH:/run/current-system/sw/bin/
             printf "VSCodium with extensions:\n"
             export PS1='\n\[\033[1;34m\][vcode\w]\$\[\033[0m\] '
           '';
        };
    in
    {
      inherit packages devShells;
    });
}
