{
  stdenvNoCC,
  aerothemeplasma-icons-repo
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-icons";
  version = "2026-08-31";
  src = aerothemeplasma-icons-repo;

  installPhase = ''
    runHook preUnpack
    mkdir -p $out/share/icons
    cp -r 'Windows 7 Aero' $out/share/icons
    runHook postUnpack
  '';
  dontFixup = true;
}