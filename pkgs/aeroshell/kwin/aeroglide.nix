{
  stdenv,
  aeroshell-kwin-repo,
  kdePackages,
  wayland-protocols,
  pkg-config,
  cmake,
  ninja,
  lib,
  session ? "wayland"
}:
stdenv.mkDerivation {
  pname = "aeroshell-aeroglide-${session}";
  version = if session == "wayland" then "2026-06-18" else "2026-06-21";
  src = aeroshell-kwin-repo;

  preConfigure = ''
    substituteInPlace effects_cpp/${session}/aeroglide/src/{metadata.json,CMakeLists.txt} --replace-fail \
      "kwin_aeroglide_config" "kwin_aeroglide_${session}_config"
  '' + lib.optionalString (session == "x11") ''
    # on X11 whether the glide plays for plasmashell windows is reliant on this hardcoded
    # window class, since patched plasmashell is built as aeroshell they were gliding :(
    substituteInPlace effects_cpp/x11/aeroglide/src/glide.cpp --replace-fail \
      '"plasmashell org.kde.plasmashell"' '"aeroshell plasmashell"'
  '';
  buildInputs = [ kdePackages.qttools wayland-protocols ]
    ++ lib.optionals (session == "x11") [ kdePackages.kwin-x11 ]
    ++ lib.optionals (session == "wayland") [ kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  cmakeFlags = [ (lib.cmakeBool "KWIN_BUILD_WAYLAND" (session == "wayland")) ];
  ninjaFlags = [ "aeroglide${lib.optionalString (session == "x11") "-x11"}" ];
  installTargets = "effects_cpp/${session}/aeroglide/install";
}