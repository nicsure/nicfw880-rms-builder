# Release Files

Coloca aquí tus archivos ZIP para el pipeline de construcción:

- `osx-arm64.zip` - Construcción de macOS ARM64
- `osx-x64.zip` - Construcción de macOS x86_64

El workflow de GitHub Actions usará automáticamente estos archivos para crear bundles universales.

## Convención de nombres de archivos
- Los archivos deben llamarse exactamente `osx-arm64.zip` y `osx-x64.zip`
- Cada ZIP debe contener el bundle de aplicación de macOS listo para empaquetar

## Uso
1. Sube tus archivos ZIP a esta carpeta
2. Haz commit y push al repositorio
3. El workflow se ejecutará automáticamente al detectar cambios en `to_release/`
4. También puedes ejecutar el workflow manualmente desde GitHub Actions

## Estructura esperada del ZIP
```
osx-arm64.zip
└── NicFW880_RMS.app/
    ├── Contents/
    │   ├── Info.plist
    │   ├── MacOS/
    │   │   └── NicFW880_RMS
    │   └── Resources/
    └── ...
```