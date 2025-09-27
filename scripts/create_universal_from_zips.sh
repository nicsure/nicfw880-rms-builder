#!/bin/bash

# Script to create universal bundle from .zip files
# Usage: ./create_universal_from_zips.sh <zip_arm64> <zip_x64> <executable_name>

set -e

if [ $# -ne 3 ]; then
    echo "Usage: $0 <zip_arm64> <zip_x64> <executable_name>"
    echo "Example: $0 osx-arm64.zip osx-x64.zip NicFW880_RMS"
    exit 1
fi

ZIP_ARM64="$1"
ZIP_X64="$2"
EXECUTABLE_NAME="$3"
BUNDLE_NAME="${EXECUTABLE_NAME}.app"

# Verify that .zip files exist
if [ ! -f "$ZIP_ARM64" ] || [ ! -f "$ZIP_X64" ]; then
    echo "Error: One or both .zip files do not exist"
    exit 1
fi

echo "🗂️  Cleaning temporary directories..."
rm -rf temp_arm64 temp_x64 "$BUNDLE_NAME"

echo "📦 Extracting $ZIP_ARM64..."
mkdir -p temp_arm64
unzip -q "$ZIP_ARM64" -d temp_arm64

echo "📦 Extracting $ZIP_X64..."
mkdir -p temp_x64
unzip -q "$ZIP_X64" -d temp_x64

# Find the executable in the extracted directories
ARM64_EXEC=$(find temp_arm64 -name "$EXECUTABLE_NAME" -type f | head -1)
X64_EXEC=$(find temp_x64 -name "$EXECUTABLE_NAME" -type f | head -1)

if [ -z "$ARM64_EXEC" ] || [ -z "$X64_EXEC" ]; then
    echo "Error: Could not find executable '$EXECUTABLE_NAME' in one or both .zip files"
    echo "ARM64: $ARM64_EXEC"
    echo "X64: $X64_EXEC"
    exit 1
fi

# Get base directories where executables are located
ARM64_DIR=$(dirname "$ARM64_EXEC")
X64_DIR=$(dirname "$X64_EXEC")

echo "📁 ARM64 executable found in: $ARM64_DIR"
echo "📁 X64 executable found in: $X64_DIR"

echo "🔨 Creating universal bundle $BUNDLE_NAME..."

# Create bundle structure
mkdir -p "$BUNDLE_NAME/Contents/MacOS"
mkdir -p "$BUNDLE_NAME/Contents/Resources"

echo "📝 Creating Info.plist..."
cat > "$BUNDLE_NAME/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleExecutable</key>
	<string>$EXECUTABLE_NAME</string>
	<key>CFBundleIdentifier</key>
	<string>com.company.$(echo $EXECUTABLE_NAME | tr '[:upper:]' '[:lower:]')</string>
	<key>CFBundleName</key>
	<string>$EXECUTABLE_NAME</string>
	<key>CFBundleDisplayName</key>
	<string>$EXECUTABLE_NAME</string>
	<key>CFBundleVersion</key>
	<string>1.0</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleSignature</key>
	<string>????</string>
	<key>LSMinimumSystemVersion</key>
	<string>10.15</string>
	<key>CFBundleSupportedPlatforms</key>
	<array>
		<string>MacOSX</string>
	</array>
	<key>LSArchitecturePriority</key>
	<array>
		<string>arm64</string>
		<string>x86_64</string>
	</array>
</dict>
</plist>
EOF

# Add execution permissions to extracted binaries
echo "🔓 Adding execution permissions..."
chmod +x "$ARM64_EXEC"
chmod +x "$X64_EXEC"

echo "🔗 Creating universal binary..."
lipo -create \
    "$ARM64_EXEC" \
    "$X64_EXEC" \
    -output "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo "📚 Copying libraries (using ARM64 as base)..."

# Copy all .dylib libraries from ARM64 (they are identical on both platforms)
for lib in $(find "$ARM64_DIR" -name "*.dylib" -exec basename {} \; 2>/dev/null); do
    echo "  📚 $lib"
    cp "$ARM64_DIR/$lib" "$BUNDLE_NAME/Contents/MacOS/"
done

# Copy other files (not .dylib and not the executable)
echo "📄 Copying additional files..."
for file in $(find "$ARM64_DIR" -type f ! -name "*.dylib" ! -name "$EXECUTABLE_NAME" -exec basename {} \; 2>/dev/null | sort -u); do
    if [ -f "$ARM64_DIR/$file" ]; then
        echo "  📄 $file"
        cp "$ARM64_DIR/$file" "$BUNDLE_NAME/Contents/MacOS/"
    fi
done

# Set permissions for final executable
chmod +x "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo "🧹 Cleaning temporary files..."
rm -rf temp_arm64 temp_x64

echo ""
echo "✅ Universal bundle created: $BUNDLE_NAME"

# Verify architectures
echo "🔍 Verifying executable architectures:"
lipo -info "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo ""
echo "📦 Bundle contents:"
ls -la "$BUNDLE_NAME/Contents/MacOS/"