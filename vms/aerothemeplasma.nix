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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.plymouth.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.defaultSession = "aerothemeplasma";

  aerothemeplasma = {
    enable = true;
    plasma.enable = true;
    fonts.enable = true;
    plymouth.enable = true;
    sddm.enable = true;
    polkit.enable = true;
  };
  programs = {
    sevulet.enable = true;
    linver.enable = true;
  };
}
