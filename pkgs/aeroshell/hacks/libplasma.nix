{
  kdePackages,
  fetchFromGitLab,
  fetchzip,
  runCommand,
  diffutils,
  lib
}:
let
  patch-source = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "libplasma";
    rev = "d514f51b73a77b15cbefb76923937af5d6a73b63";
    hash = "sha256-q3r9AxGfvNIH5f5StT2SwrnDU+JfUaXSJCeC4U06Fhc=";
    forceFetchGit = true;
  };
  patch-target = fetchFromGitLab {
    domain = "invent.kde.org";
    owner = "plasma";
    repo = "libplasma";
    rev = "47b0743f639672749837255a0db9e5edd3e954fa";
    hash = "sha256-34M6cCe+/tZSx8wO6SzKJ/XlokAyo2/jMgF4xufp6hI=";
  };
in
kdePackages.libplasma.overrideAttrs (oldAttrs: {
  pname = "aeroshell-libplasma";
  patches = [(
    runCommand "aeroshell-libplasma-patches" { nativeBuildInputs = [diffutils]; } ''
      cd ${patch-source}
      diff -ru ${patch-target}/src ./src > $out || test $? -eq 1
    ''
  )];
  postPatch = ''
    shopt -s globstar

    substituteInPlace src/**/CMakeLists.txt \
      --replace-warn 'URI "org.kde.plasma.' 'URI "io.gitgud.wackyideas.plasma.' \
      --replace-warn "EXPORT_NAME Plasma" "OUTPUT_NAME ATPlasma"
    substituteInPlace src/**/*.qml --replace-quiet "import org.kde.plasma." "import io.gitgud.wackyideas.plasma."

    substituteInPlace src/declarativeimports/core/tooltipdialog.cpp --replace-fail \
      'component(m_engine.get(), "org.kde.plasma.' 'component(m_engine.get(), "io.gitgud.wackyideas.plasma.'

    substituteInPlace src/declarativeimports/CMakeLists.txt --replace-fail "add_subdirectory(kirigamiplasmastyle)" ""
    substituteInPlace src/plasma/CMakeLists.txt --replace-fail "add_subdirectory(packagestructure)" ""
  '';
  ninjaFlags = ["corebindingsplugin"];
  postFixup = "rm -rf $out/share";
})
