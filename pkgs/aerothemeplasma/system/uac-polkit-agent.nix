{
  stdenv,
  pkgs,
  aeroshell-uac-repo,
  cmake,
  kdePackages,
}:
stdenv.mkDerivation {
  pname = "aeroshell-uac-polkit-agent";
  src = aeroshell-uac-repo;
  version = "2026-02-25";

  buildInputs = with kdePackages; [
    qtbase
    qtdeclarative
    kcoreaddons
    ki18n
    kwindowsystem
    knotifications
    kdbusaddons
    kcrash
    kconfig
    polkit-qt-1
  ];

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.wrapQtAppsHook
  ];

  # From: https://github.com/DuCanhGH/snowflakes/blob/766fd883850f1d8592386e3b422fd4ff8778e6b8/modules/nixos/aero/kde/uac-polkit-agent.nix#L4
  postFixup = ''
    rm -rf $out/share/systemd/user/uac-polkit-agent.service
    substituteInPlace $out/etc/systemd/user/plasma-polkit-agent.service.d/uac-polkit-agent.conf \
      --replace-fail "/bin/sh" "${pkgs.bash}/bin/bash" \
      --replace-fail "$out/libexec/polkit-kde-authentication-agent-1" "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1"
  '';
}
