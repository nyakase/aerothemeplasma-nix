{
  lib,
  writeShellApplication,
  coreutils,
  git,
  gh,
  jq,
  nix
}:
writeShellApplication {
  name = "nyakisatoizer";
  runtimeInputs = [
    coreutils
    git
    gh
    jq
    nix
  ];
  text = ''
    : "''${GITHUB_ACTIONS:=false}"
    export NIX_CONFIG="warn-dirty = false"

    targetablePkgsList() {
      #shellcheck disable=SC2016
      nix eval .#packages.x86_64-linux --raw --impure --inputs-from . --apply 'pkgs: 
        let
          lib = (builtins.getFlake "nixpkgs").lib;
          updatablePkgs = lib.filterAttrs (n: v: v ? "passthru"."updateScript") pkgs;
          sharedSrcs = lib.filterAttrs (n: v: lib.hasSuffix "-repo" n) pkgs;

          pkgToSharedSrc = pkgName: pkg: lib.mapAttrs'\'''
            (srcName: _: lib.nameValuePair srcName {''${pkgName} = pkg;}) 
            (lib.filterAttrs (_: src: pkg.src == src) sharedSrcs);
          
          pkgToTarget = pkgName: pkg:
            let 
              sharedSrc = pkgToSharedSrc pkgName pkg; 
            in 
              if sharedSrc == {}
              then {"''${pkgName}" = {"''${pkgName}" = pkg;};} 
              else sharedSrc;
          
          targetablePkgs = lib.foldlAttrs (acc: pkgName: pkg: 
            lib.recursiveUpdate acc (pkgToTarget pkgName pkg)
          ) {} updatablePkgs;
        in
          lib.concatMapAttrsStringSep "\n" (srcName: src: 
            "''${srcName}\t''${lib.concatStringsSep " " (lib.attrNames src)}"
          ) targetablePkgs
      '
    }
    wrappedUpdateScript() {
      #shellcheck disable=SC2016
      nix build "$(nix eval ".#$1" --raw --impure --inputs-from . --apply '
        pkg:
        let
          pkgs = (builtins.getFlake "nixpkgs").legacyPackages.x86_64-linux;
          inherit (pkgs) lib;
        in
          (pkgs.writeShellScript "updateScript" (
            lib.escapeShellArgs pkg.passthru.updateScript.command
          )).drvPath
      ')^out" --no-link --print-out-paths
    }
    pkgAttr() {
      nix eval --raw "git+file://$PWD?ref=senpai&shallow=1#$1.$2"
    }

    declare -A targetablePkgs
    while IFS=$'\t' read -r target pkgs; do
      targetablePkgs["$target"]="$pkgs"
    done < <(targetablePkgsList)

    targets=("$@")
    if ((''${#targets[@]} == 0)); then
      mapfile -t targets < <(printf '%s\n' "''${!targetablePkgs[@]}" | sort)
    else
      for target in "''${targets[@]}"; do
        if [[ ! -v "targetablePkgs[$target]" ]]; then
          echo "nyakisatoizer: unrecognized target $target" >&2
          exit 1
        fi
      done
    fi

    for target in "''${targets[@]}"; do
      read -ra packages <<< "''${targetablePkgs[$target]}"
      pkgCount=''${#packages[@]}
      targetCommitMsg=""
      targetCommitFiles=()

      if [ "$GITHUB_ACTIONS" = "true" ]; then
        if git ls-remote --exit-code --heads origin "update/$target" >/dev/null; then
          git fetch origin "update/$target"
          git switch -C "update/$target" FETCH_HEAD
          if ! git rebase --onto senpai HEAD^; then
            git rebase --abort
            git reset --hard senpai
          fi
        else
          git switch -C "update/$target" senpai
        fi
      fi

      for (( i=0; i<pkgCount; i++ )); do
        pkg="''${packages[i]}"
        echo "$target: updating $pkg.. ($(( i+1 ))/$pkgCount)"

        script="$(wrappedUpdateScript "$pkg")"
        scriptData="$(
          export NYAKISATO_TARGET="$target"
          export NYAKISATO_DIRECTORY="nyakisato/$target"
          export NYAKISATO_CLONEPHOBIC="$(( i>0 ))"
          # https://github.com/NixOS/nixpkgs/blob/d5bc1cee853d807ae425851c84c225098ed07d45/pkgs/README.md#how-are-update-scripts-executed
          UPDATE_NIX_NAME="$(pkgAttr "$pkg" name)"
          UPDATE_NIX_PNAME="$(pkgAttr "$pkg" pname)"
          UPDATE_NIX_OLD_VERSION="$(pkgAttr "$pkg" version)"
          UPDATE_NIX_ATTR_PATH="$pkg"
          export UPDATE_NIX_NAME UPDATE_NIX_PNAME UPDATE_NIX_OLD_VERSION UPDATE_NIX_ATTR_PATH
          "$script"
        )"

        if [[ -n "$scriptData" ]]; then
          if [[ "$scriptData" == "itsupdatedidc" ]]; then
            echo "$target: already up to date (donesies!)"
            continue 2
          else
            if (( i == 0 )); then
              targetCommitMsg=$(jq -r '.[0].commitMessage' <<< "$scriptData")
              targetCommitBody=$(jq -r '.[0].commitBody' <<< "$scriptData")
            fi
            
            mapfile -t packageModdedFiles < <(jq -r '.[0].files[]' <<< "$scriptData")
            targetCommitFiles+=("''${packageModdedFiles[@]}")
          fi
        fi
      done

      if [[ "$GITHUB_ACTIONS" = "true" ]] && ! git diff --quiet; then
        echo "$target: committing changes.."
        git reset senpai
        git add -- "''${targetCommitFiles[@]}"
        git commit -m "$targetCommitMsg"
        git push origin HEAD --force-with-lease

        openPR=$(gh pr list --repo "$GITHUB_REPOSITORY" --state open --author @nyakisato --head "update/$target" --json url --jq .[0].url)
        PRbody="
Try this in the VM:
\`\`\`bash
nix run --impure github:nix-community/nixGL -- nix run github:$REPO_NAME/update/$target#nixosConfigurations.atp.config.system.build.vm
\`\`\`
$targetCommitBody
"
        
        if [[ -n "$openPR" ]]; then
          echo "$target: editing pull request.."
          GH_TOKEN="$GHA_TOKEN" gh pr edit "$openPR" --title "$targetCommitMsg" --body "$PRbody"
        else
          echo "$target: making pull request.."
          GH_TOKEN="$GHA_TOKEN" gh pr create --repo "$GITHUB_REPOSITORY" --title "$targetCommitMsg" --body "$PRbody" --assignee @nyakase --reviewer @nyakase
        fi
      fi

      echo "$targetCommitMsg (donesies!)"
    done
  '';
}
