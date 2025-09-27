#!/bin/bash

# Script to create professional DMG with installation layout
# Usage: ./create_dmg.sh <app_name.app> [dmg_name]

set -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <app_name.app> [dmg_name]"
    echo "Example: $0 NicFW880_RMS.app"
    echo "Example: $0 NicFW880_RMS.app MyApplication-v1.0"
    exit 1
fi

APP_BUNDLE="$1"
DMG_NAME="${2:-$(basename "$APP_BUNDLE" .app)}"
TEMP_DMG="${DMG_NAME}_temp.dmg"
FINAL_DMG="${DMG_NAME}.dmg"
MOUNT_POINT="/Volumes/${DMG_NAME}"
STAGING_DIR="dmg_staging"

# Verify that the bundle exists
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: Bundle '$APP_BUNDLE' does not exist"
    exit 1
fi

echo "📦 Creating professional DMG for $APP_BUNDLE..."

# Clean previous files
rm -rf "$STAGING_DIR" "$TEMP_DMG" "$FINAL_DMG"

# Create staging directory
mkdir -p "$STAGING_DIR"

echo "📋 Copying application to staging..."
cp -R "$APP_BUNDLE" "$STAGING_DIR/"

echo "🔗 Creating link to Applications..."
ln -s /Applications "$STAGING_DIR/Applications"

echo "💾 Calculating required size..."
# Calculate content size plus 20% margin
SIZE_MB=$(du -sm "$STAGING_DIR" | cut -f1)
SIZE_MB=$((SIZE_MB + SIZE_MB/5 + 10)) # Add 20% + 10MB margin

echo "🔨 Creating temporary DMG (${SIZE_MB}MB)..."
hdiutil create -size ${SIZE_MB}m -fs HFS+ -volname "$DMG_NAME" "$TEMP_DMG"

echo "📁 Mounting temporary DMG..."
hdiutil attach "$TEMP_DMG" -mountpoint "$MOUNT_POINT" -nobrowse

echo "📋 Copying content..."
cp -R "$STAGING_DIR"/* "$MOUNT_POINT/"

echo "💤 Waiting for synchronization..."
sleep 3

echo "📤 Unmounting DMG..."
hdiutil detach "$MOUNT_POINT"

echo "🗜️  Creating final compressed DMG..."
hdiutil convert "$TEMP_DMG" -format UDZO -o "$FINAL_DMG"

echo "🧹 Cleaning temporary files..."
rm -rf "$STAGING_DIR" "$TEMP_DMG"

echo ""
echo "✅ DMG created successfully: $FINAL_DMG"

# Show DMG information
echo "📊 DMG information:"
ls -lh "$FINAL_DMG"