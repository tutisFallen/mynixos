{
  description = "Setup do Tutis - Xeon v4 + RX 580 + CachyOS Kernel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Repositório CachyOS / Chaotic Nyx
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms.url = "github:AvengeMedia/DankMaterialShell";
    dgop.url = "github:AvengeMedia/dgop";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      flake = {
        nixosConfigurations.nixos-tutis = inputs.nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          modules = [
            # 1. Injeção de Overlays e Configurações Globais
            {
              nixpkgs.config.allowUnfree = true;
              nixpkgs.overlays = [ inputs.chaotic.overlays.default ];
            }

            # 2. Módulos Externos (Importados apenas aqui)
            inputs.chaotic.nixosModules.default
            inputs.home-manager.nixosModules.home-manager

            # 3. Configuração Local do Host
            ./system/configuration.nix

            # 4. Configuração do Home Manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              #fazer backup essa merda trava o rb toda vez
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.tutis = import ./modules/home.nix;
            }
          ];
        };
      };
    };
}
