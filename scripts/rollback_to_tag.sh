#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <tag-name>"
  exit 1
fi

tag_name="$1"

git fetch --tags

if ! git rev-parse "$tag_name" >/dev/null 2>&1; then
  echo "Tag not found: $tag_name"
  exit 1
fi

git checkout "$tag_name"
echo "Checked out $tag_name. Trigger the manual rollback workflow to redeploy this snapshot."
