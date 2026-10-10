{
  stdenvNoCC,
  aerothemeplasma-repo
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-shell";
  version = "2026-03-16";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/plasma/shells
    cp -r $src/plasma/shells/io.gitgud.wackyideas.desktop $out/share/plasma/shells
    
    substituteInPlace $out/share/plasma/shells/io.gitgud.wackyideas.desktop/contents/configuration/ConfigurationContainmentAppearance.qml \
      --replace-fail "kwin_aeroglassblur_config.so" 'kwin_aeroglassblur_''${XDG_SESSION_TYPE}_config.so'
    
    runHook postInstall
  '';
}