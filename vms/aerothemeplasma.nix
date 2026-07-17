{
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "26.05";
  virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 4;
    qemu.options = ["-device virtio-vga-gl" "-device virtio-sound" "-display spice-app,gl=on"];
  };
  users.users.anon = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    password = "anon";
  };
  time.timeZone = "Europe/Oslo";
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.plymouth.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "aerothemeplasma";
  services.xserver.enable = true;

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
  programs = {
    linver.enable = true;
    execbin.enable = true;
  };

  # to avoid a repeat of https://github.com/nyakase/aerothemeplasma-nix/issues/24
  documentation.nixos.includeAllModules = true;
}
