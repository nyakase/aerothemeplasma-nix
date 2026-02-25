{
  description = "AeroThemePlasma on NixOS";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ self, withSystem, moduleWithSystem, ... }: {
      systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" ];

      flake.nixosModules.aerothemeplasma-nix = moduleWithSystem (
        perSystem@{ config }: import ./modules/default.nix perSystem
      );
      flake.homeModules.aerothemeplasma-nix = throw ''
        aerothemeplasma-nix's home-manager module has been removed for Plasma 6.6, as the theme
        now comes with an "Out of the Box Experience" program that can configure itself. It is stabler
        than attempting to enable AeroThemePlasma through plasma-manager, which has a few odd quirks.

        Please remove aerothemeplasma from home-manager and add aerothemeplasma.plasma.enable = true;
        to your system configuration instead. You will see the Experience open on your next login. Note
        that your plasma-manager settings could override settings set by the Experience if conflicting.
      '';

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
              rev = "4a47f711819b4fafe88179b22b32c99ae4e33cdd";
              hash = "sha256-TOuJ9f7yiNdMaWXv7P1vaSEBhx85v94XZ8ptZzs+ptw=";
            };
            aeroshell-smod-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "smod";
              rev = "292e5a0d2e9730068e91c1160de184302baf86a2";
              hash = "sha256-p55yWLo+lNnarJlhvPcTdrRMhYSJKYsuITpxG3sJ8Ds=";
            };
            aeroshell-workspace-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "aeroshell-workspace";
              rev = "ceb31c1d4aac43955e0195c627a57bf45f511990";
              hash = "sha256-nVuO+MioCku/isljfRQgEv2sRclOF/QdPBNPZs6Kd6M=";
            };
            aerothemeplasma-icons-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "atp/aerothemeplasma-icons";
              rev = "44dbe78b76c8b0d55343428b6b179716c36fd7f6";
              hash = "sha256-jBTUgLpxhT/tVB5JTeAcxJ8zNyAK8gffGAiq3fOF1LE=";
            };
            aerothemeplasma-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "atp/aerothemeplasma";
              rev = "c7e74773709e9d03a04e15d143867f4a89d849f4";
              hash = "sha256-qzgTgPB7bbI25fjmWlqSHFFDpFJKcqBpqOCWLyUANyk=";
            };
            aeroshell-uac-repo = pkgs.fetchFromGitLab {
              domain = "gitgud.io";
              owner = "aeroshell";
              repo = "uac-polkit-agent";
              rev = "f284a37b688c0f57984fd1604c1134c2629a8028";
              hash = "sha256-E+UV0cRZcrQNtFkDQXfQPxtayKkamzLybElLFLNc26o=";
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
            smod = self.callPackage ./pkgs/aeroshell/kwin/smod.nix {};
            smodglow = self.callPackage ./pkgs/aeroshell/kwin/smodglow.nix {};
            smodsnap = self.callPackage ./pkgs/aeroshell/kwin/smodsnap.nix {};
            squashaero = self.callPackage ./pkgs/aeroshell/kwin/squashaero.nix {};
            thumbnail-aero = self.callPackage ./pkgs/aeroshell/kwin/thumbnail-aero.nix {};

            kcmloader = self.callPackage ./pkgs/aeroshell/plasma/kcmloader.nix {};
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
            notifications = self.callPackage ./pkgs/aerothemeplasma/plasmoids/notifications.nix {};
            panel = self.callPackage ./pkgs/aerothemeplasma/plasmoids/panel.nix {};
            sevenstart = self.callPackage ./pkgs/aerothemeplasma/plasmoids/sevenstart.nix {};
            seventasks = self.callPackage ./pkgs/aerothemeplasma/plasmoids/seventasks.nix {};
            systemtray = self.callPackage ./pkgs/aerothemeplasma/plasmoids/systemtray.nix {};
            volume = self.callPackage ./pkgs/aerothemeplasma/plasmoids/volume.nix {};
            win7showdesktop = self.callPackage ./pkgs/aerothemeplasma/plasmoids/win7showdesktop.nix {};

            login-session = self.callPackage ./pkgs/aerothemeplasma/system/login-session.nix {};
            sddm-theme-mod = self.callPackage ./pkgs/aerothemeplasma/system/sddm-theme-mod.nix {};
            uac-polkit-agent = self.callPackage ./pkgs/aerothemeplasma/system/uac-polkit-agent.nix {};

            segoe-ui = self.callPackage ./pkgs/external/fonts/segoe-ui.nix {};
            lucida-console = self.callPackage ./pkgs/external/fonts/lucida-console.nix {};

            aeroglasspane = self.callPackage ./pkgs/external/software/aeroglasspane.nix {};
            plymouthvista = self.callPackage ./pkgs/external/system/plymouthvista.nix {};
            linver = self.callPackage ./pkgs/external/software/linver.nix {};

            sevulet-explorer = self.callPackage ./pkgs/external/software/sevulet/explorer.nix {};
            sevulet-notepad = self.callPackage ./pkgs/external/software/sevulet/notepad.nix {};
            sevulet-photoview = self.callPackage ./pkgs/external/software/sevulet/photoview.nix {};
            sevulet-stickies = self.callPackage ./pkgs/external/software/sevulet/stickies.nix {};
          })
        );
      };
    });
}