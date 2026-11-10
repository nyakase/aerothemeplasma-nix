{
  stdenv,
  fetchFromGitLab,
  kdePackages,
  cmake,
  nyakisato
}:
stdenv.mkDerivation {
  pname = "execbin";
  version = "2026-02-24";
  src = fetchFromGitLab {
    domain = "gitgud.io";
    owner = "catpswin56";
    repo = "execbin";
    rev = "6127849ad534b07d44b278b14f2246cf43ada3b9";
    hash = "sha256-7zVfwLVw9DEmVFA8RGZb+1Jt7KF0iJG0dPqvPFZzZN0=";
    forceFetchGit = true;
  };

  buildInputs = with kdePackages; [ extra-cmake-modules qtbase kwindowsystem ];
  nativeBuildInputs = [ cmake kdePackages.wrapQtAppsHook ];

  passthru.updateScript = nyakisato { };
}
