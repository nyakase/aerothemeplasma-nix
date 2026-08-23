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
  pname = "aeroshell-aeroglassblur-${session}";
  version = if session == "wayland" then "2026-08-08" else "2026-06-21";
  src = aeroshell-kwin-repo;

  preConfigure = ''
    substituteInPlace effects_cpp/${session}/kde-effects-aeroglassblur/src/{metadata.json,kcm/CMakeLists.txt} --replace-fail \
      "kwin_aeroglassblur_config" "kwin_aeroglassblur_${session}_config"
  '';
  buildInputs = [ kdePackages.qttools wayland-protocols ]
    ++ lib.optionals (session == "x11") [ kdePackages.kwin-x11 ]
    ++ lib.optionals (session == "wayland") [ kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config ninja kdePackages.wrapQtAppsHook ];
  cmakeFlags = [ (lib.cmakeBool "KWIN_BUILD_WAYLAND" (session == "wayland")) ];
  ninjaFlags = [ "aeroglassblur${lib.optionalString (session == "x11") "-x11"}" ];
  installTargets = "effects_cpp/${session}/kde-effects-aeroglassblur/install";
}
