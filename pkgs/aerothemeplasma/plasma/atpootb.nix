{
  stdenv,
  aerothemeplasma-repo,
  kdePackages,
  cmake,
}:
stdenv.mkDerivation {
  pname = "aerothemeplasma-atpootb";
  version = "2026-02-21";
  src = aerothemeplasma-repo;

  preConfigure = "cd plasma/atpootb";

  postPatch = ''
    substituteInPlace plasma/atpootb/src/CMakeLists.txt \
    --replace-fail "\''${CMAKE_INSTALL_PREFIX}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml" "${kdePackages.kwin}/share/dbus-1/interfaces/org.kde.kwin.Effects.xml"
  '';

  buildInputs = with kdePackages; [kwin qttools];
  nativeBuildInputs = [cmake kdePackages.wrapQtAppsHook];

  cmakeFlags = [
    "-DKAUTH_ACTIONS_QML=false"
  ];

  meta = {
    mainProgram = "atpootb";
  };
}
