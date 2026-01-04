#!/bin/sh

set -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <planet.pmtiles>"
  exit 1
fi

PLANET_PM="$1"

if [ ! -f "$PLANET_PM" ]; then
  echo "Error: $PLANET_PM not found"
  exit 1
fi

# Output directory
OUT_DIR="outputs"
mkdir -p "$OUT_DIR"

echo "▶ Creating low-zoom planet extract (z0–6)..."

./pmtiles extract \
  "$PLANET_PM" \
  "$OUT_DIR/planet-0-6.pmtiles" \
  --minzoom=0 \
  --maxzoom=6

echo "✔ planet-0-6.pmtiles created"

echo
echo "▶ Creating regional extracts (z7–13)..."

for GEOJSON in *.geojson; do
  [ -e "$GEOJSON" ] || continue

  NAME=$(basename "$GEOJSON" .geojson)

  # Capitalize first letter for output (mongolia → Mongolia.pmtiles)
  # NAME="$(printf "%s" "$BASENAME" | sed 's/^./\U&/')"

  OUT_PM="$OUT_DIR/$NAME.pmtiles"

  echo "  • Processing $GEOJSON → $NAME.pmtiles"

  ./pmtiles extract \
    "$PLANET_PM" \
    "$OUT_PM" \
    --region="$GEOJSON" \
    --minzoom=7 \
    --maxzoom=13

  echo "    ✔ $OUT_PM created"
done

echo
echo "✅ All extracts completed"

