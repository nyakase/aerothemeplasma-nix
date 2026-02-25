# AeroThemePlasma on NixOS
This [flake](https://wiki.nixos.org/wiki/Flakes) can be used to install the Wayland version of [AeroThemePlasma](https://gitgud.io/wackyideas/aerothemeplasma) on a NixOS unstable system.

![Demo of AeroThemePlasma on a running NixOS system](demo.png)

## Installation
### Fonts
Skip this section if you don't want to use `aerothemeplasma.fonts.enable` (required for the Plymouth theme).

Please get some font files from an up-to-date install of Windows 7. To check the version of a font with fontconfig, use `fc-query -f "%{fontversion}" FILE.ttf`. The expected files from C:\Windows\Fonts are as follows:

* Segoe UI: segoeui.ttf (336200), segoeuib.ttf (336200), segoeuii.ttf (336200), seguisb.ttf (327680)
* Lucida Console: lucon.ttf (327680)

Add the font files to the Nix store with `nix store add-file FILE.ttf`.

### Modules
Add aerothemeplasma-nix as a flake input and NixOS module. 

<details>
<summary>Example</summary>

```nix
# ./flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    aerothemeplasma-nix = {
      url = "github:nyakase/aerothemeplasma-nix";
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
To install the theme, add this to your NixOS configuration:
```nix
# ./configuration.nix
boot.plymouth.enable = true;
services.displayManager.sddm.enable = true;
services.desktopManager.plasma6.enable = true;
services.displayManager.defaultSession = "aerothemeplasma"; # if you want

aerothemeplasma = {
  enable = true;
  plasma.enable = true;
  fonts.enable = true;
  plymouth.enable = true;
  sddm.enable = true;
  polkit.enable = true;
};
```

### Use it
Rebuild and reboot your system. You can open the session list with the bottom-left button if using the SDDM theme. Select the "AeroThemePlasma (Wayland)" session if not pre-selected.

When booting into the session for the first time, a setup wizard will launch and help you finish applying the Plasma theme. Have fun!

## Potential questions
### Why is X11 unsupported?
[Plasma's X11 session will be dropped in 2027.](https://blogs.kde.org/2025/11/26/going-all-in-on-a-wayland-future/) There are [some minor issues](https://gitgud.io/wackyideas/aerothemeplasma/-/blob/master/DOCUMENTATION.md#current-wayland-issues-) with using AeroThemePlasma on Wayland, but for the most part it works nicely, so I don't want to double the flake surface for something that is going away soon.

### Why did tooltips break after restarting `plasmashell`?
Under the AeroThemePlasma session it's called `aeroshell`, so you should restart that instead. If you use `plasmashell`, it will start without the tooltip patch.

### Why did some parts of the theme reset when I rebuilt?
Do you use [plasma-manager](https://github.com/nix-community/plasma-manager)? If settings in plasma-manager conflict with what was set by the AeroThemePlasma setup wizard, or you are using `programs.plasma.overrideConfig`, the theme settings may be overridden.

### Why is this section called "Potential questions"?
I can't call them frequently asked questions when I haven't been asked them a single time yet!

## Special thanks
* [WackyIdeas](https://github.com/WackyIdeas) and contributors for developing [AeroThemePlasma](https://gitgud.io/wackyideas/aerothemeplasma)
* [aean0x](https://github.com/aean0x/.dotfiles/tree/20a3dd32b3ddbd752c93c9f38e03e76dbbd3ce87/aerotheme) and [Rotlug](https://github.com/Rotlug/aerothemeplasma-nixos) for prior art in packaging AeroThemePlasma, though this flake deviates significantly
* [ech0devv](https://github.com/ech0devv) and [Rotlug](https://github.com/Rotlug) for writing derivations for [the Sevulet suite](pkgs/external/software/sevulet) and [`atpootb`](pkgs/aerothemeplasma/plasma/atpootb.nix) respectively
* [DuCanhGH](<https://github.com/DuCanhGH/snowflakes/tree/main/modules/nixos/aero>) for additional prior art in packaging AeroThemePlasma, and being friendly about it
* Chris Lejman of [brokenTONE](https://brokentone.net) for creating the ["Not so ordinary life"](https://brokentone.net/wall/147-not-so-ordinary-life/) wallpaper, used in the demo screenshot

### [It's fun to stay at the](https://music.youtube.com/watch?v=RN8Li7kYNnw&t=57) C.E.L.A.
THIS PROJECT IS IN NO WAY AFFILIATED WITH THE MICROSOFT GROUP OF COMPANIES. Windows® and Segoe® are registered trademarks of the Microsoft Corporation in the United States. This project does not aim to, and does not, distribute copies of the Microsoft Corporation's famous Windows® 7 operating system and associated fonts.
