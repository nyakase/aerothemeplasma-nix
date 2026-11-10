{
  lib,
  stdenvNoCC,
  fetchFromGitLab,
  nyakisato
}:
stdenvNoCC.mkDerivation {
  pname = "aerothemeplasma-sounds";
  version = "2026-01-09";
  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "aeroshell";
    repo = "atp/aerothemeplasma-sounds";
    rev = "55d2f5fd15f53cccbbb13388941b930442db1159";
    hash = "sha256-z73owMl2+mAQJKGgjuJAmPIYOYuoVug0nWZ3WqWY0DY=";
    forceFetchGit = true;
  };

  # not using upstream's CMakeLists here because.. it's just files
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/sounds
    cp -r Windows* $out/share/sounds
    runHook postInstall
  '';
  dontFixup = true;

  passthru.updateScript = nyakisato {
    subpaths = [
      "Windows 7 Afternoon"
      "Windows 7 Calligraphy"
      "Windows 7 Characters"
      "Windows 7 Cityscape"
      "Windows 7 Delta"
      "Windows 7 Festival"
      "Windows 7 Garden"
      "Windows 7 Heritage"
      "Windows 7 Landscape"
      "Windows 7 Quirky" # me too
      "Windows 7 Raga"
      "Windows 7 Savanna"
      "Windows 7 Sonata"
      "Windows 7"
    ];
  };
}