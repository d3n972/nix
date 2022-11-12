{
  description = "My Nix(OS) configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    nixpkgsUnstable.url = "nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-22.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
    nix-colors.url = "github:misterio77/nix-colors";
  };

  outputs = { self, nixpkgs, nixpkgsUnstable, nur, home-manager, darwin, ... }@inputs:
    let
      lib = nixpkgs.lib;

      systemOverlay = (
        final: prev: {
          keyd = prev.callPackage ./pkgs/keyd/default.nix { };
        }
      );

      linuxHomeOverlay = (
        final: prev: {
          neovim = inputs.nixpkgsUnstable.legacyPackages.${prev.system}.neovim;
          waybar = inputs.nixpkgsUnstable.legacyPackages.${prev.system}.waybar;
          scaleway-cli = inputs.nixpkgsUnstable.legacyPackages.${prev.system}.scaleway-cli;
          gopls = inputs.nixpkgsUnstable.legacyPackages.${prev.system}.gopls;
          whitesur-gtk-theme = inputs.nixpkgsUnstable.legacyPackages.${prev.system}.whitesur-gtk-theme;
          whitesur-icon-theme = inputs.nixpkgsUnstable.legacyPackages.${prev.system}.whitesur-icon-theme;
          lr-tech-rofi-themes = prev.callPackage ./pkgs/lr-tech-rofi-themes/default.nix { };
        }
      );
    in
    {
      nixosConfigurations = {
        mark-desktop = lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
            {
              nixpkgs.overlays = [ systemOverlay nur.overlay ];
            }

            ./hosts/mark-desktop
            ./users/mark/system

            ./modules/nixos/keyd.nix
          ];
        };

        mark-g15 = lib.nixosSystem {
          system = "x86_64-linux";

          specialArgs = { inherit inputs; };

          modules = [
            {
              nixpkgs.overlays = [ systemOverlay nur.overlay ];
            }

            ./hosts/mark-g15
            ./users/mark/system

            ./modules/nixos/keyd.nix
          ];
        };
      };

      darwinConfigurations = {
        Mark-M1-MacBook-Pro = darwin.lib.darwinSystem {
          system = "aarch64-darwin";

          modules = [
            {
              programs.bash.enable = false;
            }
            {
              nix.extraOptions = ''
                experimental-features = nix-command flakes
              '';

              # nix.useDaemon = true;
              services.nix-daemon.enable = true;
              services.nix-daemon.enableSocketListener = true;
            }
            {
              system.defaults.NSGlobalDomain.KeyRepeat = 1;
              system.defaults.NSGlobalDomain.InitialKeyRepeat = 15;
            }
            {
              homebrew = {
                enable = true;

                casks = [
                  "raycast"
                ];
              };
            }
          ];
        };
      };

      homeConfigurations = {
        "mark@mark-desktop" = home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";

          username = "mark";
          homeDirectory = "/home/mark";

          pkgs = import nixpkgs {
            inherit system;

            config.allowUnfree = true;

            overlays = [
              linuxHomeOverlay
            ];
          };

          extraModules = [
            ./modules/home-manager
            inputs.nix-colors.homeManagerModule
          ];

          extraSpecialArgs = { inherit inputs; };

          configuration = {
            imports = [
              ./home.nix
              ./users/mark/home/nix-colors.nix
              ./users/mark/home/linux.nix
              ./users/mark/home/dev.nix
              ./users/mark/home/programs/git.nix
              ./users/mark/home/programs/kitty
              ./users/mark/home/programs/neomutt.nix
            ];
          };
        };

        "mark@mark-g15" = home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-linux";

          username = "mark";
          homeDirectory = "/home/mark";

          pkgs = import nixpkgs {
            inherit system;

            config.allowUnfree = true;

            overlays = [
              linuxHomeOverlay

              (
                final: prev: {
                  libsForQt5 = prev.libsForQt5 // {
                    qtstyleplugin-kvantum = prev.libsForQt5.qtstyleplugin-kvantum.overrideAttrs (
                      o: rec {
                        patches = [ ./pkgs/kvantum/kvantum.patch ];
                        patchFlags = [ "-p2" ];
                        cmakeFlags = [ "-DCMAKE_INSTALL_PREFIX=$(out)" ];
                        makeFlags = [ "PREFIX=$(out)" ];
                      }
                    );
                  };
                }
              )
            ];
          };

          extraModules = [
            ./modules/home-manager
            inputs.nix-colors.homeManagerModule
          ];

          extraSpecialArgs = { inherit inputs; };

          configuration = {
            imports = [
              ./home.nix
              ./users/mark/home/nix-colors.nix
              ./users/mark/home/gtk.nix
              ./users/mark/home/linux.nix
              ./users/mark/home/sway.nix
              ./users/mark/home/dev.nix
              ./users/mark/home/programs/git.nix
              ./users/mark/home/programs/kitty
              ./users/mark/home/programs/neomutt.nix
            ];
          };
        };

        "marksk@MARKSK-M-J1W8" = home-manager.lib.homeManagerConfiguration rec {
          system = "x86_64-darwin";

          username = "marksk";
          homeDirectory = "/Users/marksk";

          pkgs = import nixpkgsUnstable {
            inherit system;

            overlays = [ ];
          };

          extraModules = [
            ./modules/home-manager
            inputs.nix-colors.homeManagerModule
          ];

          extraSpecialArgs = { inherit inputs; };

          configuration = {
            imports = [
              ./home.nix
              ./home.darwin.nix
              ./users/mark/home/nix-colors.nix
              ./users/mark/home/dev.nix
              ./users/mark/home/programs/git.nix
              ./users/mark/home/programs/kitty
              ./users/mark/home/programs/neomutt.nix
            ];
          };
        };

        "marksk@Mark-M1-MacBook-Pro" = home-manager.lib.homeManagerConfiguration rec {
          system = "aarch64-darwin";

          username = "marksk";
          homeDirectory = "/Users/marksk";

          pkgs = import nixpkgsUnstable {
            inherit system;

            config.allowUnfree = true;

            overlays = [ nur.overlay ];
          };

          extraModules = [
            ./modules/home-manager
            inputs.nix-colors.homeManagerModule
          ];

          extraSpecialArgs = { inherit inputs; };

          configuration = {
            imports = [
              ./home.nix
              ./home.darwin.nix
              ./users/mark/home/nix-colors.nix
              ./users/mark/home/dev.nix
              ./users/mark/home/programs/git.nix
              ./users/mark/home/programs/kitty
              ./users/mark/home/programs/neomutt.nix

              {
                home.packages = with pkgs; [
                  fira-code
                  fira-code-symbols
                  iosevka
                  jetbrains-mono

                  (nerdfonts.override { fonts = [ "FiraCode" "Iosevka" "JetBrainsMono" ]; })

                  font-awesome
                  font-awesome_5
                ];
              }
            ];
          };
        };
      };
    } // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ home-manager git ];
        };
      }
    );
}
