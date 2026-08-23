{
  stdenv,
  aeroshell-smod-repo,
  kdePackages,
  pkg-config,
  smod,
  cmake,
  lib,
  session ? "wayland"
}:
stdenv.mkDerivation {
  pname = "aeroshell-smodglow-${session}";
  version = if session == "wayland" then "2026-08-22" else "2026-08-19";
  src = aeroshell-smod-repo;

  buildInputs = [ smod ]
    ++ lib.optionals (session == "x11") [ kdePackages.kwin-x11 ]
    ++ lib.optionals (session == "wayland") [ kdePackages.kwin ];
  nativeBuildInputs = [ cmake pkg-config kdePackages.wrapQtAppsHook ];
  cmakeFlags = [ 
    (lib.cmakeBool "BUILD_EFFECT" (session == "wayland"))
    (lib.cmakeBool "BUILD_EFFECTX11" (session == "x11"))
  ];
}