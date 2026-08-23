{
  description = "AeroThemePlasma on NixOS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ self, withSystem, moduleWithSystem, ... }: {
      systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" ];

      flake.nixosModules.aerothemeplasma-nix = moduleWithSystem (
        perSystem@{ config }: import ./modules/default.nix perSystem
      );

      # This configuration is intended for testing,
      # please do not try to switch to it!
      flake.nixosConfigurations.atp = inputs.nixpkgs.lib.nixosSystem {
        modules = [
          self.nixosModules.aerothemeplasma-nix
          ./vms/aerothemeplasma.nix
        ];
      };

      perSystem = { pkgs, system, ... }: {
        packages = pkgs.lib.filterAttrs (_: pkgs.lib.isDerivation) (
          pkgs.lib.makeScope pkgs.newScope (self: {
            aeroshell-kwin-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "aeroshell-kwin-components";
              rev = "b787cfe07b31374ddfd700034f9f7138e51382dc";
              hash = "sha256-xAj+JphwwabYdrGC9T3DKNanCgGXxAFHVpgfwkkI8UI=";
            };
            aeroshell-smod-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "smod";
              rev = "bc04a7b9ecbb4a8f0a88e69c1b1e4fd4ed2f358d";
              hash = "sha256-NXhiE5dzZoGKeGjLDch08OhtZvwpVH9SIy2fsKw2tC8=";
            };
            aeroshell-workspace-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "aeroshell-workspace";
              rev = "12313066fbeafb950ad9ac59d98fa4b16a33c85b";
              hash = "sha256-JQ7Mx0XL8VnrAxtDaRu46EIXePHNQZy5hNN2GIS4m94=";
            };
            aerothemeplasma-icons-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "atp/aerothemeplasma-icons";
              rev = "b8d5ce100251b74a3a3c5b4a474cb3ff8df11bba";
              hash = "sha256-4GFn8wJ8b58AwZZAyt7/0R1JTcJtamoocPjr31c8Nk4=";
            };
            aerothemeplasma-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "atp/aerothemeplasma";
              rev = "d4ca559d1ff9f26dd6652df66ecc075aa14efdc2";
              hash = "sha256-Ac8M1ZjWum41lGbR5o6uX69xez5zT2rbYqF/Sl0NXl8=";
            };
            
            libplasma = self.callPackage ./pkgs/aeroshell/hacks/libplasma.nix {};
            plasma-workspace = self.callPackage ./pkgs/aeroshell/hacks/plasma-workspace.nix {};

            aeroglassblur = self.callPackage ./pkgs/aeroshell/kwin/aeroglassblur.nix {};
            aeroglide = self.callPackage ./pkgs/aeroshell/kwin/aeroglide.nix {};
            dimscreenaero = self.callPackage ./pkgs/aeroshell/kwin/dimscreenaero.nix {};
            fadingpopupsaero = self.callPackage ./pkgs/aeroshell/kwin/fadingpopupsaero.nix {};
            flip3d = self.callPackage ./pkgs/aeroshell/kwin/flip3d.nix {};
            launchfeedback = self.callPackage ./pkgs/aeroshell/kwin/launchfeedback.nix {};
            loginaero = self.callPackage ./pkgs/aeroshell/kwin/loginaero.nix {};
            kwin-shared-data = self.callPackage ./pkgs/aeroshell/kwin/shared-data.nix {};
            smod = self.callPackage ./pkgs/aeroshell/kwin/smod.nix {};
            smodglow = self.callPackage ./pkgs/aeroshell/kwin/smodglow.nix {};
            smodsnap = self.callPackage ./pkgs/aeroshell/kwin/smodsnap.nix {};
            smodpeekeffect = self.callPackage ./pkgs/aeroshell/kwin/smodpeekeffect.nix {};
            smodpeekscript = self.callPackage ./pkgs/aeroshell/kwin/smodpeekscript.nix {};
            squashaero = self.callPackage ./pkgs/aeroshell/kwin/squashaero.nix {};
            thumbnail-aero = self.callPackage ./pkgs/aeroshell/kwin/thumbnail-aero.nix {};
            thumbnails = self.callPackage ./pkgs/aeroshell/kwin/thumbnails.nix {};

            kcmloader = self.callPackage ./pkgs/aeroshell/plasma/kcmloader.nix {};
            libaeroshellutils = self.callPackage ./pkgs/aeroshell/plasma/libaeroshellutils.nix {};
            libshowdesktop = self.callPackage ./pkgs/aeroshell/plasma/libshowdesktop.nix {};
            libtaskmanager = self.callPackage ./pkgs/aeroshell/plasma/libtaskmanager.nix {};

            cursors = self.callPackage ./pkgs/aerothemeplasma/assets/cursors.nix {};
            icons = self.callPackage ./pkgs/aerothemeplasma/assets/icons.nix {};
            sounds = self.callPackage ./pkgs/aerothemeplasma/assets/sounds.nix {};

            atpootb = self.callPackage ./pkgs/aerothemeplasma/plasma/atpootb.nix {};
            authui7 = self.callPackage ./pkgs/aerothemeplasma/plasma/authui7.nix {};
            color-scheme = self.callPackage ./pkgs/aerothemeplasma/plasma/color-scheme.nix {};
            kvantum-windows7aero = self.callPackage ./pkgs/aerothemeplasma/plasma/kvantum-windows7aero.nix {};
            layout-template = self.callPackage ./pkgs/aerothemeplasma/plasma/layout-template.nix {};
            seven-black = self.callPackage ./pkgs/aerothemeplasma/plasma/seven-black.nix {};
            shell = self.callPackage ./pkgs/aerothemeplasma/plasma/shell.nix {};
            xdg = self.callPackage ./pkgs/aerothemeplasma/plasma/xdg.nix {};

            battery = self.callPackage ./pkgs/aerothemeplasma/plasmoids/battery.nix {};
            desktopcontainment = self.callPackage ./pkgs/aerothemeplasma/plasmoids/desktopcontainment.nix {};
            digitalclocklite = self.callPackage ./pkgs/aerothemeplasma/plasmoids/digitalclocklite.nix {};
            keyboardlayout = self.callPackage ./pkgs/aerothemeplasma/plasmoids/keyboardlayout.nix {};
            networkmanagement = self.callPackage ./pkgs/aerothemeplasma/plasmoids/networkmanagement.nix {};
            notifications = self.callPackage ./pkgs/aerothemeplasma/plasmoids/notifications.nix {};
            panel = self.callPackage ./pkgs/aerothemeplasma/plasmoids/panel.nix {};
            sevenstart = self.callPackage ./pkgs/aerothemeplasma/plasmoids/sevenstart.nix {};
            seventasks = self.callPackage ./pkgs/aerothemeplasma/plasmoids/seventasks.nix {};
            systemtray = self.callPackage ./pkgs/aerothemeplasma/plasmoids/systemtray.nix {};
            volume = self.callPackage ./pkgs/aerothemeplasma/plasmoids/volume.nix {};
            win7showdesktop = self.callPackage ./pkgs/aerothemeplasma/plasmoids/win7showdesktop.nix {};

            login-session = self.callPackage ./pkgs/aerothemeplasma/system/login-session.nix {};
            sddm-theme-mod = self.callPackage ./pkgs/aerothemeplasma/system/sddm-theme-mod.nix {};

            segoe-ui = self.callPackage ./pkgs/external/fonts/segoe-ui.nix {};
            lucida-console = self.callPackage ./pkgs/external/fonts/lucida-console.nix {};

            aeroglasspane = self.callPackage ./pkgs/external/software/aeroglasspane.nix {};
            execbin = self.callPackage ./pkgs/external/software/execbin.nix {};
            linver = self.callPackage ./pkgs/external/software/linver.nix {};

            plymouthvista = self.callPackage ./pkgs/external/system/plymouthvista.nix {};
            uac-polkit-agent = self.callPackage ./pkgs/external/system/uac-polkit-agent.nix {};
          })
        );
      };
    });
}