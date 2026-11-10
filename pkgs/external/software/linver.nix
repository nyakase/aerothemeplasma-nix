{
  stdenv,
  lib,
  fetchFromGitLab,
  qt6,
  lsb-release,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "linver";
  version = "2026-01-04";

  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "wackyideas";
    repo = "linver";
    rev = "087f2746703d9c885de2e1a4f6360314283703f4";
    sha256 = "sha256-QeoXvKWuSCzH82krr6AnBpqwKFBhPaQiGEmy+N1Qz+g=";
    forceFetchGit = true;
  };

  buildInputs = [ qt6.qtbase ];
  nativeBuildInputs = [ qt6.wrapQtAppsHook qt6.qmake ];
  qmakeFlags = [ "linver.pro" ];

  postPatch = "substituteInPlace linver.pro --replace-fail 'target.path = /usr/bin' \"target.path = $out/bin\"";
  qtWrapperArgs = [ "--prefix PATH : ${lib.makeBinPath [lsb-release]}" ];

  passthru.updateScript = nyakisato { };
}
