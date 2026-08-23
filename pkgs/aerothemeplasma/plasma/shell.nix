{
  stdenvNoCC,
  aerothemeplasma-repo
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-shell";
  version = "2026-08-20";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/plasma/shells
    cp -r $src/plasma/shells/io.gitgud.wackyideas.desktop $out/share/plasma/shells
    runHook postInstall
  '';
}