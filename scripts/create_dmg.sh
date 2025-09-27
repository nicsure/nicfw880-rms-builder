#!/bin/bash

# Script para crear DMG profesional con layout de instalación
# Uso: ./create_dmg.sh <nombre_app.app> [nombre_dmg]

set -e

if [ $# -lt 1 ]; then
    echo "Uso: $0 <nombre_app.app> [nombre_dmg]"
    echo "Ejemplo: $0 NicFW880_RMS.app"
    echo "Ejemplo: $0 NicFW880_RMS.app MiAplicacion-v1.0"
    exit 1
fi

APP_BUNDLE="$1"
DMG_NAME="${2:-$(basename "$APP_BUNDLE" .app)}"
TEMP_DMG="${DMG_NAME}_temp.dmg"
FINAL_DMG="${DMG_NAME}.dmg"
MOUNT_POINT="/Volumes/${DMG_NAME}"
STAGING_DIR="dmg_staging"

# Verificar que el bundle existe
if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: El bundle '$APP_BUNDLE' no existe"
    exit 1
fi

echo "📦 Creando DMG profesional para $APP_BUNDLE..."

# Limpiar archivos previos
rm -rf "$STAGING_DIR" "$TEMP_DMG" "$FINAL_DMG"

# Crear directorio de staging
mkdir -p "$STAGING_DIR"

echo "📋 Copiando aplicación al staging..."
cp -R "$APP_BUNDLE" "$STAGING_DIR/"

echo "🔗 Creando enlace a Aplicaciones..."
ln -s /Applications "$STAGING_DIR/Applications"

echo "🎨 Creando imagen de fondo..."
# Crear una imagen de fondo simple con texto
cat > "$STAGING_DIR/.background_script.sh" << 'EOF'
#!/bin/bash
# Este script se ejecutará para configurar el fondo
mkdir -p .background
cat > .background/instructions.txt << 'INSTRUCTIONS'
Drag the application to the Applications folder to install.

Arrastra la aplicación a la carpeta Aplicaciones para instalar.
INSTRUCTIONS
EOF

chmod +x "$STAGING_DIR/.background_script.sh"
(cd "$STAGING_DIR" && ./.background_script.sh)
rm "$STAGING_DIR/.background_script.sh"

echo "💾 Calculando tamaño necesario..."
# Calcular el tamaño del contenido más un 20% de margen
SIZE_MB=$(du -sm "$STAGING_DIR" | cut -f1)
SIZE_MB=$((SIZE_MB + SIZE_MB/5 + 10)) # Añadir 20% + 10MB de margen

echo "🔨 Creando DMG temporal (${SIZE_MB}MB)..."
hdiutil create -size ${SIZE_MB}m -fs HFS+ -volname "$DMG_NAME" "$TEMP_DMG"

echo "📁 Montando DMG temporal..."
hdiutil attach "$TEMP_DMG" -mountpoint "$MOUNT_POINT" -nobrowse

echo "📋 Copiando contenido..."
cp -R "$STAGING_DIR"/* "$MOUNT_POINT/"

# Ocultar archivos de fondo
if [ -d "$MOUNT_POINT/.background" ]; then
    chflags hidden "$MOUNT_POINT/.background"
fi

echo "🎨 Configurando layout del Finder..."

# Crear script AppleScript para configurar la vista del Finder
cat > setup_dmg_view.applescript << EOF
tell application "Finder"
    tell disk "$DMG_NAME"
        open

        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 950, 450}

        set theViewOptions to the icon view options of container window
        set arrangement of theViewOptions to not arranged
        set icon size of theViewOptions to 128
        set background picture of theViewOptions to file ".background:instructions.txt"

        -- Posicionar iconos
        set position of item "$APP_BUNDLE" of container window to {150, 200}
        set position of item "Applications" of container window to {400, 200}

        close
        open

        update without registering applications
        delay 2
    end tell
end tell
EOF

# Intentar ejecutar el script AppleScript (puede fallar en algunos sistemas)
echo "🎯 Intentando configurar vista..."
if command -v osascript >/dev/null 2>&1; then
    osascript setup_dmg_view.applescript 2>/dev/null || echo "⚠️  No se pudo configurar la vista automáticamente"
else
    echo "⚠️  osascript no disponible, configuración manual necesaria"
fi

rm -f setup_dmg_view.applescript

echo "💤 Esperando sincronización..."
sleep 3

echo "📤 Desmontando DMG..."
hdiutil detach "$MOUNT_POINT"

echo "🗜️  Creando DMG final comprimida..."
hdiutil convert "$TEMP_DMG" -format UDZO -o "$FINAL_DMG"

echo "🧹 Limpiando archivos temporales..."
rm -rf "$STAGING_DIR" "$TEMP_DMG"

echo ""
echo "✅ DMG creada exitosamente: $FINAL_DMG"

# Mostrar información de la DMG
echo "📊 Información de la DMG:"
ls -lh "$FINAL_DMG"

echo ""
echo "🚀 Para probar: open $FINAL_DMG"
echo "📝 Para distribución: La DMG está lista para compartir"