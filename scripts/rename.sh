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

# Define target folders where replacements should happen
TARGET_FOLDERS=(
    "$BASE_DIR"
    "$BASE_DIR/res/css"
    "$BASE_DIR/res/css/components/views/polls"
    "$BASE_DIR/res/css/structures"
    "$BASE_DIR/res/css/views/audio_messages"
    "$BASE_DIR/res/css/views/avatars"
    "$BASE_DIR/res/css/views/context_menus"
    "$BASE_DIR/res/css/views/dialogs"
    "$BASE_DIR/res/css/views/dialogs/security"
    "$BASE_DIR/res/css/views/directory"
    "$BASE_DIR/res/css/views/elements"
    "$BASE_DIR/res/css/views/messages"
    "$BASE_DIR/res/css/views/right_panel"
    "$BASE_DIR/res/css/views/rooms"
    "$BASE_DIR/res/css/views/settings/tabs/user"
    "$BASE_DIR/res/css/views/spaces"
    "$BASE_DIR/res/css/views/toasts"
    "$BASE_DIR/res/css/views/voip"
    "$BASE_DIR/res/css/views/voip/LegacyCallView"
    "$BASE_DIR/res/themes/legacy-light/css"
    "$BASE_DIR/res/themes/light/css"
    "$BASE_DIR/src"
    "$BASE_DIR/src/async-components/structures"
    "$BASE_DIR/src/async-components/views/dialogs/security"
    "$BASE_DIR/src/components/structures"
    "$BASE_DIR/src/components/structures/auth"
    "$BASE_DIR/src/components/views/auth"
    "$BASE_DIR/src/components/views/avatars"
    "$BASE_DIR/src/components/views/beacon"
    "$BASE_DIR/src/components/views/context_menus"
    "$BASE_DIR/src/components/views/dialogs"
    "$BASE_DIR/src/components/views/dialogs/security"
    "$BASE_DIR/src/components/views/elements"
    "$BASE_DIR/src/components/views/location"
    "$BASE_DIR/src/components/views/messages"
    "$BASE_DIR/src/components/views/pips"
    "$BASE_DIR/src/components/views/polls/pollHistory"
    "$BASE_DIR/src/components/views/right_panel"
    "$BASE_DIR/src/components/views/right_panel/user_info"
    "$BASE_DIR/src/components/views/rooms"
    "$BASE_DIR/src/components/views/rooms/EventTile"
    "$BASE_DIR/src/components/views/rooms/MemberList"
    "$BASE_DIR/src/components/views/rooms/MemberList/tiles/common"
    "$BASE_DIR/src/components/views/rooms/RoomHeader"
    "$BASE_DIR/src/components/views/rooms/RoomListPanel"
    "$BASE_DIR/src/components/views/rooms/wysiwyg_composer"
    "$BASE_DIR/src/components/views/rooms/wysiwyg_composer/components"
    "$BASE_DIR/src/components/views/settings"
    "$BASE_DIR/src/components/views/settings/devices"
    "$BASE_DIR/src/components/views/settings/encryption"
    "$BASE_DIR/src/components/views/settings/tabs/user"
    "$BASE_DIR/src/components/views/spaces/threads-activity-centre"
    "$BASE_DIR/src/shared-components/audio/PlayPauseButton"
    "$BASE_DIR/src/toasts"
    "$BASE_DIR/src/vector"
    "$BASE_DIR/test/unit-tests/components/views/settings/encryption"
)

echo ""
echo "=== Processing icon references in target folders ==="

# Counter for tracking
total_files=0

# Process each target folder
for folder in "${TARGET_FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        # Find all files in this folder (not recursive into subfolders)
        find "$folder" -maxdepth 1 -type f | while read -r file; do
            # Check if file contains /icons/ pattern
            if grep -q "/icons/" "$file" 2>/dev/null; then
                echo "Processing: $file"
                # Replace /icons/[anything].svg with /ui-icons/[anything].svg
                sed -i 's|/icons/\([^"'\''[:space:]]*\.svg\)|/ui-icons/\1|g' "$file"
                ((total_files++))
            fi
        done
    fi
done

echo "=== Completed processing ==="
echo ""

# --- Handle index.html separately (uses "icons/" without leading slash) ---
INDEX_FILE="$BASE_DIR/index.html"

if [ -f "$INDEX_FILE" ]; then
    echo "Processing index.html with pattern: icons/*.svg -> ui-icons/*.svg"
    sed -i 's|icons/\([^"'\''[:space:]]*\.svg\)|ui-icons/\1|g' "$INDEX_FILE"
    echo "Updated index.html"
fi

# --- Rename icons folder to ui-icons ---
ICON_DIR="$BASE_DIR/icons"
UI_ICON_DIR="$BASE_DIR/ui-icons"

if [ -d "$ICON_DIR" ]; then
    mv "$ICON_DIR" "$UI_ICON_DIR"
    echo "Renamed folder: $ICON_DIR -> $UI_ICON_DIR"
fi

echo ""
echo "=== Script completed successfully ==="
