#!/bin/bash

# Create an x86_64-only .app bundle from a single x64 zip
# Usage: ./create_x64_app_from_zip.sh <zip_x64> <executable_name>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <zip_x64> <executable_name>"
    echo "Example: $0 to_release/osx-x64.zip NicFW880_RMS"
    exit 1
fi

ZIP_X64="$1"
EXECUTABLE_NAME="$2"
BUNDLE_NAME="${EXECUTABLE_NAME}.app"

if [ ! -f "$ZIP_X64" ]; then
    echo "Error: zip not found: $ZIP_X64"
    exit 1
fi

echo "🗂️  Cleaning..."
rm -rf temp_x64 "$BUNDLE_NAME"

echo "📦 Extracting $ZIP_X64..."
mkdir -p temp_x64
unzip -q "$ZIP_X64" -d temp_x64

X64_EXEC=$(find temp_x64 -name "$EXECUTABLE_NAME" -type f | head -1)
if [ -z "$X64_EXEC" ]; then
    echo "Error: executable '$EXECUTABLE_NAME' not found in $ZIP_X64"
    exit 1
fi
X64_DIR=$(dirname "$X64_EXEC")

echo "📁 x64 executable found in: $X64_DIR"

echo "🔨 Creating bundle $BUNDLE_NAME..."
mkdir -p "$BUNDLE_NAME/Contents/MacOS"
mkdir -p "$BUNDLE_NAME/Contents/Resources"

echo "📝 Writing Info.plist..."
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
        <string>x86_64</string>
    </array>
</dict>
</plist>
EOF

echo "🔓 Making executable..."
chmod +x "$X64_EXEC"
cp "$X64_EXEC" "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo "📚 Copying libraries from x64 zip..."
for lib in $(find "$X64_DIR" -maxdepth 1 -name "*.dylib" -exec basename {} \; 2>/dev/null); do
    echo "  📚 $lib"
    cp "$X64_DIR/$lib" "$BUNDLE_NAME/Contents/MacOS/"
done

echo "📄 Copying additional files..."
for file in $(find "$X64_DIR" -maxdepth 1 -type f ! -name "*.dylib" ! -name "$EXECUTABLE_NAME" -exec basename {} \; 2>/dev/null | sort -u); do
    echo "  📄 $file"
    cp "$X64_DIR/$file" "$BUNDLE_NAME/Contents/MacOS/"
done

echo "🧹 Cleaning temp..."
rm -rf temp_x64

echo "✅ x86_64 bundle created: $BUNDLE_NAME"

echo "🔍 Verifying arch:"
lipo -info "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo "🚀 To open: open $BUNDLE_NAME"


