# AeroThemePlasma on NixOS
This [flake](https://wiki.nixos.org/wiki/Flakes) can be used to install [AeroThemePlasma](https://gitgud.io/wackyideas/aerothemeplasma) on a NixOS 26.05 system. For unstable systems, [use the senpai branch](https://github.com/nyakase/aerothemeplasma-nix/tree/senpai).

![Demo of AeroThemePlasma on a running NixOS system](demo.png)

## Installation

### Modules
Add aerothemeplasma-nix as a flake input and NixOS module. 

<details>
<summary>Example flake.nix</summary>

```nix
# ./flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    aerothemeplasma-nix = {
      url = "github:nyakase/aerothemeplasma-nix/26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = inputs@{ nixpkgs, aerothemeplasma-nix, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        aerothemeplasma-nix.nixosModules.aerothemeplasma-nix
      ];
    };
  }
}
```

</details>

### Configuration
To install the theme, add this to your NixOS configuration (edge cases are described below):

```nix
boot.plymouth.enable = true;
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
services.displayManager.defaultSession = "aerothemeplasma"; # for x11, append x11

programs.aeroshell = {
  enable = true;
  fonts.segoe.enable = true;
  polkit.enable = true;
  aerothemeplasma = {
    enable = true;
    sddm.enable = true;
    plymouth.enable = true;
  };
};
```

#### Disabling sessions
If you have the X server enabled (`services.xserver.enable = true;`), some effects will compile for both Wayland and X11 by default. If you know you will only use one with the theme, you can save yourself time by disabling the other: `programs.aeroshell.sessions.<wayland/x11>.enable = false;`.

Please remember that [KDE is dropping their X11 session in Plasma 6.8](https://blogs.kde.org/2025/11/26/going-all-in-on-a-wayland-future) which will release [around mid-October 2026](https://community.kde.org/Schedules/Plasma_6#Future_releases), and the AeroShell developers [have stated](https://wackyideas.neocities.org/blogposts/2026/03/01/aerothemeplasma-new-version#wayland) that they intend to drop all X11 support then.

#### Lucida Console font
If you use full disk encryption, Plymouth shows a password screen [(though NixOS doesn't support that by default)](https://github.com/NixOS/nixpkgs/issues/26722#issuecomment-1693500074). The Lucida Console font is used for the screen, which can be enabled with `programs.aeroshell.fonts.lucida.enable = true;` but you must obtain a copy from Windows 7 yourself.

Grab it from `C:\Windows\Fonts\lucon.ttf`. Its version should be 327680, which you can check with `fc-query -f "%{fontversion}" lucon.ttf`. Then add it to your Nix store with `nix store add-file lucon.ttf`.

### Go to town
Rebuild and reboot your system. You can open the session list with the bottom-left button if using the SDDM theme. Select one of the AeroThemePlasma sessions if not pre-selected.

When booting into the session for the first time, a setup wizard will launch and help you finish applying the Plasma theme. Have fun!

## Uninstallation
Remove the [NixOS module](#modules) and [associated options](#configuration) from your configuration. You can switch back to your old theme in [System Settings](https://userbase.kde.org/System_Settings):

1. Under "Colors & Themes", pick your old Global Theme (the default is Breeze).
2. Under "Text & Fonts", choose your old fonts (the default is Noto Sans).

Lastly, delete the `~/.config/aerothemeplasmarc` file. Not doing so prevents the setup wizard from launching on reinstallation.

## Potential questions

### Why did tooltips break after restarting `plasmashell`?
Under the AeroThemePlasma session it's called `aeroshell`, so you should restart that instead. If you use `plasmashell`, it will start without the tooltip patch.

### Why did some parts of the theme reset when I rebuilt?
Do you use [plasma-manager](https://github.com/nix-community/plasma-manager)? If settings in plasma-manager conflict with what was set by the AeroThemePlasma setup wizard, or you are using `programs.plasma.overrideConfig`, the theme settings may be overridden.

### Why is this section called "Potential questions"?
I can't call them frequently asked questions when I haven't been asked them a single time yet!

## Special thanks
* [WackyIdeas](https://github.com/WackyIdeas) and contributors for developing [AeroThemePlasma](https://gitgud.io/wackyideas/aerothemeplasma)
* [aean0x](https://github.com/aean0x/.dotfiles/tree/20a3dd32b3ddbd752c93c9f38e03e76dbbd3ce87/aerotheme) and [Rotlug](https://github.com/Rotlug/aerothemeplasma-nixos) for prior art in packaging AeroThemePlasma, though this flake deviates significantly
* [ech0devv](https://github.com/ech0devv) and [Rotlug](https://github.com/Rotlug) for writing derivations for [the Sevulet suite](https://github.com/nyakase/aerothemeplasma-nix/pull/14) and [`atpootb`](pkgs/aerothemeplasma/plasma/atpootb.nix) respectively
* [DuCanhGH](<https://github.com/DuCanhGH/snowflakes/tree/main/modules/nixos/aero>) for additional prior art in packaging AeroThemePlasma, and being friendly about it
* Chris Lejman of [brokenTONE](https://brokentone.net) for creating the ["Not so ordinary life"](https://brokentone.net/wall/147-not-so-ordinary-life/) wallpaper, used in the demo screenshot

### [It's fun to stay at the](https://music.youtube.com/watch?v=RN8Li7kYNnw&t=57) C.E.L.A.
THIS PROJECT IS IN NO WAY AFFILIATED WITH THE MICROSOFT GROUP OF COMPANIES. Windows® and Segoe® are registered trademarks of the Microsoft Corporation in the United States. This project does not aim to, and does not, distribute copies of the Microsoft Corporation's famous Windows® 7 operating system and associated fonts. The version of Segoe® used in the [`segoe-ui`](pkgs/external/fonts/segoe-ui.nix) package is retrieved from [a Microsoft repository under the MIT license](https://github.com/microsoft/MixedReality-AzureCommunicationServices-Sample/blob/0be22d2d10aa8172053206fa3d3a29799817313a/LICENSE).
