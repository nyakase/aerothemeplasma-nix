{
  kdePackages,
  libplasma,
  lib
}:
kdePackages.plasma-workspace.overrideAttrs (oldAttrs: {
  pname = "aeroshell";
  outputs = lib.remove "sessions" oldAttrs.outputs;
  cmakeFlags = oldAttrs.cmakeFlags ++ [
    (lib.cmakeFeature "Plasma_DIR" "${libplasma.dev}/lib/cmake/Plasma")
    (lib.cmakeFeature "PlasmaQuick_DIR" "${libplasma.dev}/lib/cmake/PlasmaQuick")
  ];
  ninjaFlags = [ "plasmashell" ];

  postPatch = ''
    # rename plasmashell
    echo "set_target_properties(plasmashell PROPERTIES OUTPUT_NAME aeroshell)" >> CMakeLists.txt
    substituteInPlace shell/plasma-plasmashell.service.in \
      --replace-fail "BINDIR@/plasmashell" "BINDIR@/aeroshell"

    # stuff providable by main plasma-workspace
    sed -i "/kconf_update/d; /DBUSINTERFACE/d" shell/CMakeLists.txt
    substituteInPlace shell/CMakeLists.txt --replace-fail "PW::KWorkspace" "${kdePackages.plasma-workspace}/lib/libkworkspace6.so"
    echo 'target_include_directories(plasmashell PRIVATE "${kdePackages.plasma-workspace.dev}/include/kworkspace6")' >> CMakeLists.txt

    # rename the plasmashell service
    mv shell/plasma-plasmashell.service.in shell/plasma-aeroshell.service.in
    substituteInPlace shell/CMakeLists.txt \
      --replace-fail "plasma-plasmashell.service" "plasma-aeroshell.service"

    # systemd doesn't like that two services occupy the same bus name even
    # if they'll never run at the same time, so we have to use type=simple
    substituteInPlace shell/plasma-aeroshell.service.in \
      --replace-fail "Type=dbus" "Type=simple" \
      --replace-fail "BusName=org.kde.plasmashell" "" \
      --replace-fail "Description=KDE Plasma Workspace" "Description=AeroShell Workspace"

    # rename desktop file and fix its plasmashell reference
    mv shell/org.kde.plasmashell.desktop.cmake shell/io.gitgud.wackyideas.aeroshell.desktop.cmake
    substituteInPlace shell/CMakeLists.txt \
      --replace-fail "org.kde.plasmashell.desktop" "io.gitgud.wackyideas.aeroshell.desktop"
    substituteInPlace shell/io.gitgud.wackyideas.aeroshell.desktop.cmake \
      --replace-fail "PREFIX@/bin/plasmashell" "PREFIX@/bin/aeroshell"
  '';
  installPhase = ''
    runHook preInstall
    ninja shell/install
    rm -rf $out/lib
    
    # drop-ins to make startplasma prefer aeroshell over plasmashell in the theme's login session
    mkdir -p $out/share/systemd/user/plasma-{core.target,plasmashell.service,aeroshell.service}.d

    cat > $out/share/systemd/user/plasma-core.target.d/aeroshell.conf << EOF
    [Unit]
    Wants=plasma-aeroshell.service
    EOF
    cat > $out/share/systemd/user/plasma-plasmashell.service.d/aeroshell.conf << EOF
    [Unit]
    ConditionEnvironment=!PLASMA_DEFAULT_SHELL=io.gitgud.wackyideas.desktop
    EOF
    cat > $out/share/systemd/user/plasma-aeroshell.service.d/aeroshell.conf << EOF
    [Unit]
    ConditionEnvironment=PLASMA_DEFAULT_SHELL=io.gitgud.wackyideas.desktop
    EOF

    runHook postInstall
  '';
  # prevent patching plasma-sourceenv.sh which is not built here
  postInstall = "";
})
