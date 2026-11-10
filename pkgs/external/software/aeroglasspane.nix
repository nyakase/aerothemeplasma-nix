{
  stdenv,
  lib,
  fetchFromGitLab,
  kdePackages,
  cmake,
  qt6,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "aeroglasspane";
  version = "2026-04-21";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "wackyideas";
    repo = "aero-glass-pane";
    rev = "a976b1e0498cde890e2b4f042c4b0567a890b4bb";
    hash = "sha256-Yo3vlrLfnBheHnwGfIBSCfhOOAqZxcAtcpgKC6Zvv0w=";
    forceFetchGit = true;
  };

  buildInputs = [ qt6.qtbase kdePackages.kwindowsystem ];
  nativeBuildInputs = [ cmake qt6.wrapQtAppsHook ];

  meta = {
    mainProgram = "aero-glass-pane";
  };

  passthru.updateScript = nyakisato { };
}
