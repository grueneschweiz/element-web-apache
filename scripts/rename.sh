#!/bin/bash

# Accept source and destination directories as arguments
SOURCE_DIR="${1:-.}"
DEST_DIR="${2:-./processed}"

echo "Starting script in folder: $(pwd)"
echo "Source directory: $SOURCE_DIR"
echo "Destination directory: $DEST_DIR"

# Clean up destination directory if it exists
if [ -d "$DEST_DIR" ]; then
    echo "Removing existing destination directory: $DEST_DIR"
    rm -rf "$DEST_DIR"
fi

# Create fresh destination directory
mkdir -p "$DEST_DIR"

# Copy source to destination
cp -r "$SOURCE_DIR"/* "$DEST_DIR/"
echo "Copied files from $SOURCE_DIR to $DEST_DIR"

# Work in the destination directory
BASE_DIR="$DEST_DIR"

echo ""
echo "=== Processing icon references with regex ==="

# Process all CSS files in bundles directory
if [ -d "$BASE_DIR/bundles" ]; then
    find "$BASE_DIR/bundles" -type f -name "*.css" | while read -r file; do
        if grep -q "icons/" "$file" 2>/dev/null; then
            echo "Processing: $file"
            # Replace both /icons/ and ../../icons/ patterns with /ui-icons/ and ../../ui-icons/
            sed -i 's|/icons/\([^")]*\.svg\)|/ui-icons/\1|g' "$file"
            sed -i 's|\.\./\.\./icons/\([^")]*\.svg\)|../../ui-icons/\1|g' "$file"
        fi
    done
fi

# Handle index.html (uses "icons/" without leading slash)
INDEX_FILE="$BASE_DIR/index.html"
if [ -f "$INDEX_FILE" ]; then
    echo "Processing: $INDEX_FILE"
    sed -i 's|icons/\([^"'\''[:space:]]*\.svg\)|ui-icons/\1|g' "$INDEX_FILE"
fi

echo "=== Completed processing ==="
echo ""

# --- Rename icons folder to ui-icons ---
ICON_DIR="$BASE_DIR/icons"
UI_ICON_DIR="$BASE_DIR/ui-icons"

if [ -d "$ICON_DIR" ]; then
    mv "$ICON_DIR" "$UI_ICON_DIR"
    echo "Renamed folder: $ICON_DIR -> $UI_ICON_DIR"
fi

echo ""
echo "=== Script completed successfully ==="
