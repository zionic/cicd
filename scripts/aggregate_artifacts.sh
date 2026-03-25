#!/usr/bin/env bash
set -euo pipefail

MANIFEST_PATH="${1:-config/projects.json}"
OUTPUT_DIR="${2:-site}"
WORK_DIR=".tmp/artifacts"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed." >&2
  exit 1
fi

if [[ ! -f "$MANIFEST_PATH" ]]; then
  echo "Manifest file not found: $MANIFEST_PATH" >&2
  exit 1
fi

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

# Clean previously aggregated project folders only.
find "$OUTPUT_DIR" -mindepth 1 -maxdepth 1 -type d -exec rm -rf {} +

project_count="$(jq 'length' "$MANIFEST_PATH")"
if [[ "$project_count" -eq 0 ]]; then
  echo "No projects in manifest. Generating empty portal."
else
for i in $(seq 0 $((project_count - 1))); do
  name="$(jq -r ".[$i].name" "$MANIFEST_PATH")"
  type="$(jq -r ".[$i].type" "$MANIFEST_PATH")"
  source_url="$(jq -r ".[$i].source.url" "$MANIFEST_PATH")"
  path_prefix="$(jq -r ".[$i].pathPrefix // .[$i].name" "$MANIFEST_PATH")"
  index_doc="$(jq -r ".[$i].indexDocument // \"index.html\"" "$MANIFEST_PATH")"

  if [[ -z "$name" || "$name" == "null" || -z "$source_url" || "$source_url" == "null" ]]; then
    echo "Skipping invalid entry at index $i"
    continue
  fi

  target_dir="$OUTPUT_DIR/$path_prefix"
  mkdir -p "$target_dir"

  archive_path="$WORK_DIR/${name}.zip"

  echo "Downloading artifact for [$name] from $source_url"
  curl -L --fail --retry 3 "$source_url" -o "$archive_path"

  unzip -o "$archive_path" -d "$target_dir" >/dev/null

  # Normalize Python docs style: docs/_build/html
  if [[ "$type" == "python" && -d "$target_dir/docs/_build/html" ]]; then
    mv "$target_dir/docs/_build/html"/* "$target_dir/"
    rm -rf "$target_dir/docs"
  fi

  # Normalize Java docs style: target/site
  if [[ "$type" == "java" && -d "$target_dir/target/site" ]]; then
    mv "$target_dir/target/site"/* "$target_dir/"
    rm -rf "$target_dir/target"
  fi

  # Ensure each project has index document.
  if [[ ! -f "$target_dir/$index_doc" && -f "$target_dir/index.html" ]]; then
    cp "$target_dir/index.html" "$target_dir/$index_doc"
  fi

done
fi

generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
manifest_json="$(cat "$MANIFEST_PATH")"

cat > "$OUTPUT_DIR/manifest.json" <<JSON
{
  "generatedAt": "$generated_at",
  "projects": $manifest_json
}
JSON

# Generate root landing page.
cat > "$OUTPUT_DIR/index.html" <<'HTML'
<!doctype html>
<html lang="ko">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Unified Deployment Portal</title>
    <style>
      body { font-family: Arial, sans-serif; margin: 2rem; line-height: 1.5; }
      .card { border: 1px solid #ddd; border-radius: 8px; padding: 1rem; margin-bottom: 1rem; }
      .badge { display:inline-block; padding: 0.2rem 0.5rem; border-radius: 999px; background: #eef; margin-left: 0.5rem; }
    </style>
  </head>
  <body>
    <h1>서비스 통합 배포 포털</h1>
    <p>이 페이지는 GitHub Actions가 취합한 최신 산출물을 제공합니다.</p>
    <p id="generated"></p>
    <div id="apps"></div>
    <script>
      fetch('./manifest.json')
        .then((r) => r.json())
        .then((data) => {
          document.getElementById('generated').innerText = `Last generated: ${data.generatedAt}`;
          const apps = document.getElementById('apps');
          data.projects.forEach((p) => {
            const card = document.createElement('div');
            card.className = 'card';
            card.innerHTML = `
              <h3>${p.name} <span class="badge">${p.type}</span></h3>
              <p>${p.description || ''}</p>
              <a href="./${p.pathPrefix || p.name}/">열기</a>
            `;
            apps.appendChild(card);
          });
        })
        .catch((err) => {
          document.getElementById('apps').innerText = 'manifest.json 로드 실패: ' + err;
        });
    </script>
  </body>
</html>
HTML

echo "Aggregation complete: $OUTPUT_DIR"
