#!/bin/bash

# Script para crear bundle universal desde archivos .zip
# Uso: ./create_universal_from_zips.sh <zip_arm64> <zip_x64> <nombre_ejecutable>

set -e

if [ $# -ne 3 ]; then
    echo "Uso: $0 <zip_arm64> <zip_x64> <nombre_ejecutable>"
    echo "Ejemplo: $0 osx-arm64.zip osx-x64.zip NicFW880_RMS"
    exit 1
fi

ZIP_ARM64="$1"
ZIP_X64="$2"
EXECUTABLE_NAME="$3"
BUNDLE_NAME="${EXECUTABLE_NAME}.app"

# Verificar que los archivos .zip existen
if [ ! -f "$ZIP_ARM64" ] || [ ! -f "$ZIP_X64" ]; then
    echo "Error: Uno o ambos archivos .zip no existen"
    exit 1
fi

echo "🗂️  Limpiando directorios temporales..."
rm -rf temp_arm64 temp_x64 "$BUNDLE_NAME"

echo "📦 Extrayendo $ZIP_ARM64..."
mkdir -p temp_arm64
unzip -q "$ZIP_ARM64" -d temp_arm64

echo "📦 Extrayendo $ZIP_X64..."
mkdir -p temp_x64
unzip -q "$ZIP_X64" -d temp_x64

# Buscar el ejecutable en los directorios extraídos
ARM64_EXEC=$(find temp_arm64 -name "$EXECUTABLE_NAME" -type f | head -1)
X64_EXEC=$(find temp_x64 -name "$EXECUTABLE_NAME" -type f | head -1)

if [ -z "$ARM64_EXEC" ] || [ -z "$X64_EXEC" ]; then
    echo "Error: No se encontró el ejecutable '$EXECUTABLE_NAME' en uno o ambos archivos .zip"
    echo "ARM64: $ARM64_EXEC"
    echo "X64: $X64_EXEC"
    exit 1
fi

# Obtener directorios base donde están los ejecutables
ARM64_DIR=$(dirname "$ARM64_EXEC")
X64_DIR=$(dirname "$X64_EXEC")

echo "📁 ARM64 ejecutable encontrado en: $ARM64_DIR"
echo "📁 X64 ejecutable encontrado en: $X64_DIR"

echo "🔨 Creando bundle universal $BUNDLE_NAME..."

# Crear estructura del bundle
mkdir -p "$BUNDLE_NAME/Contents/MacOS"
mkdir -p "$BUNDLE_NAME/Contents/Resources"

echo "📝 Creando Info.plist..."
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

# Agregar permisos de ejecución a los binarios extraídos
echo "🔓 Agregando permisos de ejecución..."
chmod +x "$ARM64_EXEC"
chmod +x "$X64_EXEC"

echo "🔗 Creando binario universal..."
lipo -create \
    "$ARM64_EXEC" \
    "$X64_EXEC" \
    -output "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo "📚 Copiando bibliotecas (usando ARM64 como base)..."

# Copiar todas las bibliotecas .dylib desde ARM64 (son iguales en ambas plataformas)
for lib in $(find "$ARM64_DIR" -name "*.dylib" -exec basename {} \; 2>/dev/null); do
    echo "  📚 $lib"
    cp "$ARM64_DIR/$lib" "$BUNDLE_NAME/Contents/MacOS/"
done

# Copiar otros archivos (no .dylib y no el ejecutable)
echo "📄 Copiando archivos adicionales..."
for file in $(find "$ARM64_DIR" -type f ! -name "*.dylib" ! -name "$EXECUTABLE_NAME" -exec basename {} \; 2>/dev/null | sort -u); do
    if [ -f "$ARM64_DIR/$file" ]; then
        echo "  📄 $file"
        cp "$ARM64_DIR/$file" "$BUNDLE_NAME/Contents/MacOS/"
    fi
done

# Establecer permisos del ejecutable final
chmod +x "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo "🧹 Limpiando archivos temporales..."
rm -rf temp_arm64 temp_x64

echo ""
echo "✅ Bundle universal creado: $BUNDLE_NAME"

# Verificar arquitecturas
echo "🔍 Verificando arquitecturas del ejecutable:"
lipo -info "$BUNDLE_NAME/Contents/MacOS/$EXECUTABLE_NAME"

echo ""
echo "📦 Contenido del bundle:"
ls -la "$BUNDLE_NAME/Contents/MacOS/"

echo ""
echo "🚀 Para probar: open $BUNDLE_NAME"