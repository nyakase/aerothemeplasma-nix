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
    rev = "c962fb360e5b8288b274a5294c14e8125c02aba0";
    hash = "sha256-5rqTtJArFdTrN9nzaCpQmDLkPbhBTHFVX9PdhfXKfJ4=";
    forceFetchGit = true;
  };
  patch-target = fetchzip {
    url = "mirror://kde/stable/plasma/6.8.2/libplasma-6.8.2.tar.xz";
    hash = "sha256-jXvADmf77Nb1O4HXnWxr8bLABAEXTkRsn7t1o8Jqpsc=";
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
