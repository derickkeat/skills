#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_dir="$HOME/.agents/skills"
skills=(
  commit-workflow
)

mkdir -p "$target_dir"

for skill in "${skills[@]}"; do
  source="$repo_dir/$skill"
  destination="$target_dir/$skill"
  if [[ "$destination" -ef "$source" ]]; then
    printf 'Already installed at %s\n' "$destination"
    continue
  fi
  if [[ -e "$destination" && ! -L "$destination" ]]; then
    if [[ ! -d "$destination" ]] || ! diff -qr "$source" "$destination" >/dev/null; then
      printf 'Cannot replace %s: it differs from %s.\nReview or move it, then rerun install.sh to create a symlink.\n' "$destination" "$source" >&2
      exit 1
    fi
    rm -r -- "$destination"
    printf 'Removed identical copy at %s\n' "$destination"
  fi
  ln -sfnT -- "$source" "$destination"
  printf 'Linked %s -> %s\n' "$destination" "$source"
done
