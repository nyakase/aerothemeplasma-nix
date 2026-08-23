{
  stdenv,
  lib,
  aeroshell-kwin-repo,
  kdePackages,
  cmake
}:
stdenv.mkDerivation {
  name = "aeroshell-kwin-shared-data";
  version = "2026-04-03";
  src = aeroshell-kwin-repo;
  
  postPatch = ''
    sed -i "20,22d" CMakeLists.txt
    substituteInPlace CMakeLists.txt \
      --replace-fail "add_subdirectory(effects_cpp)" "add_subdirectory(rules)"
    echo "ki18n_install(po)" >> CMakeLists.txt
  '';
  
  buildInputs = with kdePackages; [ 
    extra-cmake-modules qtbase kconfig ki18n
  ];
  nativeBuildInputs = [ cmake kdePackages.wrapQtAppsHook ];
  cmakeFlags = [ (lib.cmakeBool "KWIN_INSTALL_MISC" false) ];
}