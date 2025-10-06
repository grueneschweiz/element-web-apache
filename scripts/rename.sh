#!/bin/bash

# Accept source and destination directories as arguments
SOURCE_DIR="${1:-.}"
DEST_DIR="${2:-./processed}"

echo "Starting script in folder: $(pwd)"
echo "Source directory: $SOURCE_DIR"
echo "Destination directory: $DEST_DIR"

# Copy source to destination
cp -r "$SOURCE_DIR"/* "$DEST_DIR/"
echo "Copied files from $SOURCE_DIR to $DEST_DIR"

# Work in the destination directory
BASE_DIR="$DEST_DIR"

FILES=(
bold.b7f0698.svg copy.95010ef.svg forward.7d44a5b.svg location-pin-solid.5b99343.svg pop-out.0a8fde3.svg share-screen-solid.c7c1310.svg user-profile-solid.e886eb1.svg
check.aaad650.svg delete.8165351.svg home-solid.88e9e19.svg lock-solid.6847293.svg public.0e971dd.svg strikethrough.17fd61f.svg video-call-declined-solid.0d66d74.svg
check-circle.99c21d7.svg download.364c774.svg image.9142b42.svg mic-off-solid.b535c73.svg qr-code.b517d20.svg take-photo-solid.f40d394.svg video-call-missed-solid.f54bda6.svg
chevron-down.9ea2899.svg error-solid.7cb2e4d.svg info.d42d785.svg mic-on-solid.5e29984.svg quote.60f93d6.svg text-formatting.0b0dd78.svg video-call-off-solid.8b0f3e2.svg
chevron-left.18c22d7.svg expand.867af0b.svg info-solid.ef2d524.svg overflow-horizontal.e4b97af.svg reply.d3e6417.svg threads.52e135e.svg video-call-solid.d584e19.svg
chevron-right.a1fc7b0.svg export-archive.f43ec04.svg inline-code.f51200e.svg pause-solid.a64b426.svg restart.514c8f1.svg threads-solid.7fe60f4.svg volume-on-solid.3f0544f.svg
chevron-up.a7ca3bc.svg extensions-solid.4aa63de.svg italic.be1e35d.svg pin.7c59c5e.svg search.7258145.svg time.8c3060c.svg warning.80e5cc2.svg
close.5ef7caf.svg favourite-solid.a1d4606.svg leave.8b03b57.svg play-solid.05663a6.svg send-solid.9074f92.svg unpin.bb6290d.svg
collapse.fc765b9.svg files.453e84c.svg link.d0734d2.svg plus.95ca4d1.svg settings-solid.94c318a.svg user-add-solid.6a5ddef.svg
)

# Track unique folders that contain icon references
declare -A FOLDERS_FOUND

for filename in "${FILES[@]}"; do
    # Escape regex special chars for sed
    ESCAPED_FILENAME=$(printf '%s' "$filename" | sed 's/[.[\*^$/]/\\&/g')
    
    # Find all files containing this reference
    grep -rl "/icons/$filename" "$BASE_DIR" | while read -r file; do
        folder=$(dirname "$file")
        FOLDERS_FOUND["$folder"]=1
        echo "Found reference in: $file"
        sed -i "s|/icons/$ESCAPED_FILENAME|/ui-icons/$filename|g" "$file"
        echo "Updated: $file"
    done
done

# Log summary of folders
echo ""
echo "=== SUMMARY: Folders containing icon references ==="
find "$BASE_DIR" -type f -exec grep -l "/icons/" {} \; | while read -r file; do
    dirname "$file"
done | sort -u | while read -r folder; do
    echo "  - $folder"
done
echo "=== END SUMMARY ==="
echo ""

# --- Handle index.html separately ---
INDEX_FILE="$BASE_DIR/index.html"

if [ -f "$INDEX_FILE" ]; then
    for filename in "${FILES[@]}"; do
        # Escape regex special chars for sed
        ESCAPED_FILENAME=$(printf '%s' "$filename" | sed 's/[.[\*^$/]/\\&/g')
        sed -i "s|icons/$ESCAPED_FILENAME|ui-icons/$filename|g" "$INDEX_FILE"
    done
    echo "Updated index.html"
fi

# --- Rename icons folder to ui-icons ---
ICON_DIR="$BASE_DIR/icons"
UI_ICON_DIR="$BASE_DIR/ui-icons"

if [ -d "$ICON_DIR" ]; then
    mv "$ICON_DIR" "$UI_ICON_DIR"
    echo "Renamed folder: $ICON_DIR -> $UI_ICON_DIR"
fi
