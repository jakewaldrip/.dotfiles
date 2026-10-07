#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
MISC="$DOTFILES/misc"

usage() {
  cat <<EOF
Usage: $(basename "$0") <name> <target-dir>

Symlinks the tracked project config in misc/<name>/ into <target-dir>.

Available:
$(ls -1 "$MISC" 2>/dev/null | sed 's/^/  /')

Example:
  $(basename "$0") commons ~/code/commons
EOF
  exit 1
}

[ $# -eq 2 ] || usage

NAME="$1"
TARGET="${2/#\~/$HOME}"
SRC="$MISC/$NAME"

[ -d "$SRC" ] || { echo "No such project config: $SRC"; exit 1; }
[ -d "$TARGET" ] || { echo "Target directory does not exist: $TARGET"; exit 1; }

TARGET="$(cd "$TARGET" && pwd)"

link_one() {
  local src="$1" dest="$2"

  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      printf '    ☑ %s\n' "$(basename "$dest")"
      return
    fi
    printf '    → relinking %s\n' "$(basename "$dest")"
    rm "$dest"
  elif [ -e "$dest" ]; then
    printf '    ! %s exists and is not a symlink, skipping\n' "$(basename "$dest")"
    return
  fi

  ln -s "$src" "$dest"
  printf '    → linked %s\n' "$(basename "$dest")"
}

printf '==> Linking %s into %s\n' "$NAME" "$TARGET"

for entry in "$SRC"/* "$SRC"/.*; do
  base="$(basename "$entry")"
  case "$base" in
    . | .. | REBUILD.md) continue ;;
  esac
  [ -e "$entry" ] || continue
  link_one "$entry" "$TARGET/$base"
done

if [ -f "$SRC/.opencode/package.json" ]; then
  if command -v bun >/dev/null 2>&1; then
    printf '    → bun install in .opencode\n'
    (cd "$SRC/.opencode" && bun install)
  else
    printf '    ! bun not found, run "bun install" in %s/.opencode\n' "$SRC"
  fi
fi

printf '==> Done\n'
