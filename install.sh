#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
target_dir="$HOME/.agents/skills"
skills=(
  commit-workflow
)

mkdir -p "$target_dir"

for skill in "${skills[@]}"; do
  destination="$target_dir/$skill"
  if [[ -d "$destination" && ! -L "$destination" ]]; then
    if ! diff -qr "$repo_dir/$skill" "$destination" >/dev/null; then
      printf 'Cannot replace %s: it differs from %s.\nReview or move the existing directory, then rerun install.sh to create a symlink.\n' "$destination" "$repo_dir/$skill" >&2
      exit 1
    fi
    rm -r -- "$destination"
  fi
  ln -sfnT -- "$repo_dir/$skill" "$destination"
done
