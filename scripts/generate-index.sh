#!/bin/bash
set -e

# Generate Helm repository index.yaml
# Usage: ./scripts/generate-index.sh

CHART_DIR="${1:-.}"
OUTPUT_DIR="${2:-docs}"
REPO_URL="${3:-https://anhnguyen123312.github.io/mcp-stack}"

echo "Generating Helm index..."
echo "Chart directory: $CHART_DIR"
echo "Output directory: $OUTPUT_DIR"
echo "Repository URL: $REPO_URL"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Package all charts in directory
find "$CHART_DIR" -name "Chart.yaml" -not -path "*/.*" | while read chart_file; do
  chart_dir=$(dirname "$chart_file")
  echo "Packaging chart in $chart_dir"
  helm package "$chart_dir" -d "$OUTPUT_DIR"
done

# Generate index.yaml
helm repo index "$OUTPUT_DIR" --url "$REPO_URL"

echo ""
echo "✅ Index generated at: $OUTPUT_DIR/index.yaml"
echo ""
echo "Files in $OUTPUT_DIR:"
ls -lh "$OUTPUT_DIR"
