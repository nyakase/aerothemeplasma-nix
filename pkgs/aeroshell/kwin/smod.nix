{
  stdenv,
  aeroshell-smod-repo,
  aeroshell-kwin-repo,
  kdePackages,
  pkg-config,
  cmake,
  lib
}:
stdenv.mkDerivation {
  pname = "aeroshell-smod";
  version = "2026-08-23";
  src = aeroshell-smod-repo;

  buildInputs = with kdePackages; [
    extra-cmake-modules qtbase kcoreaddons 
    kcolorscheme kguiaddons ki18n kiconthemes 
    kwindowsystem kdecoration kcmutils
  ];
  nativeBuildInputs = [ cmake pkg-config kdePackages.wrapQtAppsHook ];
  postFixup = "rm -rf $out/share/locale && mkdir -p $out/share && cp -r ${aeroshell-kwin-repo}/smod $out/share";
  cmakeFlags = [ (lib.cmakeBool "BUILD_EFFECT" false) ];
}