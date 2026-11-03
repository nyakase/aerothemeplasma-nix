{
  stdenvNoCC,
  aerothemeplasma-repo,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-shell";
  version = "2026-11-03";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/shells
    cp -r $src/plasma/shells/io.gitgud.wackyideas.desktop $out/share/plasma/shells
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [ "plasma/shells/io.gitgud.wackyideas.desktop" ];
  };
}