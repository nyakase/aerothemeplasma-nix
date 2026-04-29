{
  stdenv,
  aerothemeplasma-repo,
  kdePackages,
  pkg-config,
  cmake
}:
stdenv.mkDerivation {
  pname = "aerothemeplasma-notifications";
  version = "2026-03-02";
  src = aerothemeplasma-repo;

  preConfigure = "cd plasma/plasmoids/src/notifications_src";
  buildInputs = with kdePackages; [
    plasma-workspace
    knotifyconfig
  ];
  nativeBuildInputs = [ cmake pkg-config kdePackages.wrapQtAppsHook ];
}