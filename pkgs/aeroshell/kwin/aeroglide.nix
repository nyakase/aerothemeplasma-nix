{
  stdenv,
  aeroshell-kwin-repo,
  kdePackages,
  pkg-config,
  cmake,
  lib,
  session ? "wayland"
}:
stdenv.mkDerivation {
  pname = "aeroshell-aeroglide-${session}";
  version = "2026-03-18";
  src = aeroshell-kwin-repo;

  preConfigure = ''
    cd effects_cpp/${session}/aeroglide
    substituteInPlace src/metadata.json src/CMakeLists.txt --replace-fail \
      "kwin_aeroglide_config" "kwin_aeroglide_${session}_config"
  '' + lib.optionalString (session == "x11") ''
    # on X11 whether the glide plays for plasmashell windows is reliant on this hardcoded
    # window class, since patched plasmashell is built as aeroshell they were gliding :(
    substituteInPlace src/glide.cpp --replace-fail \
      '"plasmashell org.kde.plasmashell"' '"aeroshell plasmashell"'
  '';
  buildInputs = [ kdePackages.qttools ] 
    ++ lib.optionals (session == "x11") [ kdePackages.kwin-x11 ]
    ++ lib.optionals (session == "wayland") [ kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config kdePackages.wrapQtAppsHook ];
  cmakeFlags = [ (lib.cmakeBool "KWIN_BUILD_WAYLAND" (session == "wayland")) ];
}