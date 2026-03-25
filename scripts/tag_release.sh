#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <tag-name> [message]"
  exit 1
fi

tag_name="$1"
message="${2:-Deploy snapshot $tag_name}"

git fetch --tags
git tag -a "$tag_name" -m "$message"
git push origin "$tag_name"

echo "Tagged and pushed: $tag_name"
