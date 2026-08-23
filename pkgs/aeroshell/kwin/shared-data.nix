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
    sed -i "24,65d" CMakeLists.txt
    substituteInPlace CMakeLists.txt \
      --replace-fail "find_package(Vulkan REQUIRED)" "find_package(KF6 ''${KF_MIN_VERSION} REQUIRED COMPONENTS Config I18n)" \
      --replace-fail "add_subdirectory(effects_cpp)" "add_subdirectory(rules)"
    echo "ki18n_install(po)" >> CMakeLists.txt
  '';
  
  buildInputs = with kdePackages; [ 
    extra-cmake-modules qtbase kconfig ki18n
  ];
  nativeBuildInputs = [ cmake kdePackages.wrapQtAppsHook ];
  cmakeFlags = [ (lib.cmakeBool "KWIN_INSTALL_MISC" false) ];
}