{
  stdenv,
  aerothemeplasma-repo,
  kdePackages,
  pkg-config,
  cmake,
  ninja,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aerothemeplasma-notifications";
  version = "2026-11-08";
  src = aerothemeplasma-repo;

  buildInputs = with kdePackages; [
    plasma-workspace
    knotifyconfig
    plasma5support
  ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  ninjaFlags = [ "io.gitgud.wackyideas.notifications" ];
  installTargets = "plasma/plasmoids/src/notifications_src/install";

  passthru.updateScript = nyakisato {
    subpaths = [ "plasma/plasmoids/src/notifications_src" ];
  };
}
