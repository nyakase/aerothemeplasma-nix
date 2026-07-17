perSystem:
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.aeroshell;
  pvcfg = if cfg.aerothemeplasma.plymouth.enable then cfg.aerothemeplasma.plymouth else cfg.vistathemeplasma.plymouth;
  atpkgs = perSystem.config.packages;
  withSessions = list: lib.concatMap (pkg:
    lib.optional cfg.sessions.wayland.enable (pkg.override { session = "wayland"; })
    ++ lib.optional cfg.sessions.x11.enable (pkg.override { session = "x11"; })
  ) list;
in
{
  # this is rather silly but if the options are dropped entirely the
  # evaluation will fail and the consumer never gets the "we've moved"
  # message, so keep these around until Plasma 6.7 or so
  options.aerothemeplasma = {
    enable = lib.mkEnableOption "nothing";
    plasma.enable = lib.mkEnableOption "nothing";
    fonts.enable = lib.mkEnableOption "nothing";
    plymouth.enable = lib.mkEnableOption "nothing";
    polkit.enable = lib.mkEnableOption "nothing";
    sddm.enable = lib.mkEnableOption "nothing";
  };
  options.programs.sevulet.enable = lib.mkEnableOption "nothing";
  
  options.programs = {
    aeroshell = rec {
      enable = lib.mkEnableOption "AeroShell";
      polkit.enable = lib.mkEnableOption "the AeroShell Polkit agent replacement";
      fonts = {
        enable = lib.mkEnableOption "the Segoe UI and Lucida Console fonts";
        segoe.enable = lib.mkEnableOption "the Segoe UI font";
        lucida.enable = lib.mkEnableOption "the Lucida Console font";
      };
      sessions = {
        wayland.enable = lib.mkEnableOption "the Wayland session" // { default = true; };
        x11.enable = lib.mkEnableOption "the X11 session" // { default = config.services.xserver.enable; };
      };
      aerothemeplasma = {
        enable = lib.mkEnableOption "AeroThemePlasma, a set of Plasma theme packages";
        plymouth.enable = lib.mkEnableOption "the PlymouthVista theme using the 7 style";
        plymouth.settings = lib.mkOption {
          description = "Settings for the PlymouthVista theme. See [PlymouthVista's CONFIG.md](https://github.com/furkrn/PlymouthVista/blob/main/CONFIG.md#keys) for a full list, ones related to services are unsupported (except BootSlowdown).";
          # "Why are they unsupported anyways?" Because they edit the Plymouth script at runtime, and since it is in the Nix store that's not happening. Maybe there is a hacky solution, but for now, ehh..
          type = lib.types.submodule {
            freeformType = with lib.types; attrsOf (oneOf [ str bool int ]);
            options.BootSlowdown = lib.mkOption {
              type = lib.types.int;
              default = 0;
              description = "Minimum duration of the PlymouthVista animation in seconds.";
            };
          };
        };
        sddm.enable = lib.mkEnableOption "the SDDM theme";
      };
      vistathemeplasma = {
        plymouth.enable = lib.mkEnableOption "the PlymouthVista theme using the Vista style";
        plymouth.settings = aerothemeplasma.plymouth.settings;
      };
    };

    linver.enable = lib.mkEnableOption "the Linver application";
    execbin.enable = lib.mkEnableOption "the ExecBin application";
  };

  config = lib.mkIf (config.aerothemeplasma.enable || cfg.enable) {
    assertions = [
      {
        assertion = cfg.aerothemeplasma.plymouth.enable -> cfg.fonts.segoe.enable;
        message = ''
          The Plymouth theme requires the Segoe font to be enabled.
          Like so: "programs.aeroshell.fonts.segoe.enable = true;"
        '';
      }
      {
        assertion = !config.aerothemeplasma.enable;
        message = ''
          The "aerothemeplasma" option set has been moved to "programs.aeroshell". This reflects 
          the changes in Plasma 6.6, fits in better with other NixOS options, and is needed to add 
          VistaThemePlasma in the future. Sorry for the trouble! For how the options work now, see:
          https://github.com/nyakase/aerothemeplasma-nix#configuration
        '';
      }
      {
        assertion = !config.programs.sevulet.enable;
        message = ''
          The Sevulet software suite was deleted by its author and is no longer available. 
          Please remove the "programs.sevulet.enable = true;" option from your configuration.
        '';
      }
      {
        assertion = cfg.sessions.wayland.enable || cfg.sessions.x11.enable;
        message = ''
          Both sessions under programs.aeroshell.sessions are disabled. How did that happen?
          Please enable one like so: programs.aeroshell.sessions.<wayland/x11>.enable = true;
        '';
      }
      {
        assertion = cfg.sessions.x11.enable -> config.services.xserver.enable;
        message = ''
          The X11 session requires the X server to be enabled.
          Enable it like so: "services.xserver.enable = true;"
        '';
      }
      {
        assertion = !(cfg.aerothemeplasma.plymouth.enable && cfg.vistathemeplasma.plymouth.enable);
        message = "Both Plymouth styles under programs.aeroshell are enabled. Choose one.";
      }
    ];

    services.displayManager.sessionPackages = lib.mkIf cfg.aerothemeplasma.enable (withSessions [ atpkgs.login-session ]);
    
    environment.systemPackages = with atpkgs; [
      pkgs.kdePackages.qtmultimedia libplasma plasma-workspace

      dimscreenaero fadingpopupsaero flip3d i18n-kwin loginaero smod 
      smodpeekeffect smodpeekscript squashaero thumbnail-aero thumbnails

      kcmloader libaeroshellutils libshowdesktop libtaskmanager
    ] ++ withSessions (with atpkgs; [
      aeroglassblur aeroglide launchfeedback smodglow smodsnap
    ]) ++ (with atpkgs; lib.optionals cfg.aerothemeplasma.enable [
      cursors icons sounds

      atpootb authui7 color-scheme kvantum-windows7aero
      layout-template seven-black shell

      battery desktopcontainment digitalclocklite keyboardlayout
      networkmanagement notifications panel sevenstart seventasks
      systemtray volume win7showdesktop

      pkgs.kdePackages.qtstyleplugin-kvantum
    ]) 
      ++ lib.optionals cfg.aerothemeplasma.sddm.enable [ atpkgs.sddm-theme-mod ]
      ++ lib.optionals config.programs.linver.enable [ atpkgs.linver ]
      ++ lib.optionals config.programs.execbin.enable [ atpkgs.execbin ];

    # backward compat for users of "programs.aeroshell.fonts.enable"
    programs.aeroshell.fonts = lib.mkIf cfg.fonts.enable {
      segoe.enable = lib.mkDefault true;
      lucida.enable = lib.mkDefault true;
    };

    fonts.packages = lib.optionals cfg.fonts.segoe.enable [ atpkgs.segoe-ui ] 
      ++ lib.optionals cfg.fonts.lucida.enable [ atpkgs.lucida-console ];
    
    systemd.packages = with atpkgs; lib.optionals cfg.polkit.enable [
      uac-polkit-agent
    ];

    boot.plymouth = lib.mkIf pvcfg.enable {
      theme = "PlymouthVista";
      themePackages = [( atpkgs.plymouthvista.override { settings = pvcfg.settings; } )];
    };
    # https://github.com/furkrn/PlymouthVista/blob/cc6592a29387462d003c2c95cb9cb5df3fea851f/systemd/slowdown/plymouth-vista-slow-boot-animation.service
    # https://wiki.archlinux.org/title/Plymouth#Slow_down_boot_to_show_the_full_animation
    systemd.services.plymouth-vista-slow-boot-animation = lib.mkIf (pvcfg.settings.BootSlowdown > 0) {
      description = "Waits for Plymouth animation to finish";
      wantedBy = [ "multi-user.target" ];
      after = [ "plymouth-start.service" ];
      before = [ "plymouth-quit.service" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${lib.getExe' pkgs.coreutils "sleep"} ${lib.toString pvcfg.settings.BootSlowdown}";
      };
    };
    programs.aeroshell.aerothemeplasma.plymouth.settings = {
      AuthuiStyle = "7";
      UseLegacyBootScreen = false;
      UseShadow = lib.mkDefault true;
    };

    services.displayManager.sddm = lib.mkIf cfg.aerothemeplasma.sddm.enable {
      theme = "sddm-theme-mod";
      extraPackages = [ pkgs.kdePackages.kitemmodels ];
      settings = {
        Theme = {
          CursorTheme = "aero-drop";
          CursorSize = 30;
          Font = lib.mkIf cfg.fonts.segoe.enable "Segoe UI";
        };
      };
    };
  };
}
