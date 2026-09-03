{
  stdenvNoCC,
  aerothemeplasma-repo
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-color-scheme";
  version = "2026-09-02";
  src = aerothemeplasma-repo;

  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/color-schemes
    cp $src/plasma/color_scheme/Aero.colors $out/share/color-schemes
    runHook postInstall
  '';
}