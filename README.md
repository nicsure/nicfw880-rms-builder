# 🍎 macOS Universal Bundle Builder

Automated GitHub Actions workflow to build universal macOS application bundles from ARM64 and x86_64 ZIP files.

## 🚀 How to Use

### Workflow

1. Create `to_release/` folder in your repo
2. Upload your ZIP files there (osx-arm64.zip and osx-x64.zip)
3. Go to **Actions** tab in your GitHub repo
4. Click **Build macOS Universal Bundle**
5. Click **Run workflow**
6. Fill in the form:
   - **Version**: `Beta3A` (or your version)
   - **Executable name**: `NicFW880_RMS` (your app name)
 
## 📦 What You Get

- 🔗 **Universal Bundle**: Single `.app` that works on ARM64 and x86_64
- 💿 **Professional DMG**: Ready-to-distribute disk image
- 📱 **GitHub Release**: Automatic release with downloadable assets
- 📋 **Build Artifacts**: Available even without releases

## 🛠️ Features

- ✅ Combines ARM64 + x86_64 binaries with `lipo`
- ✅ Creates macOS `.app` bundle with proper Info.plist
- ✅ Generates installer DMG with Applications link
- ✅ Automatic GitHub releases
- ✅ Zero local macOS dependencies - runs entirely on GitHub

## 📁 Repository Structure

```
repo/
├── .github/workflows/build-macos.yml  # GitHub Actions workflow
├── scripts/                           # Build scripts
│   ├── create_universal_from_zips.sh  # Bundle creation
│   ├── create_dmg.sh                  # DMG creation
│   └── create_x64_app_from_zip.sh     # Stopgap x86_64-only bundler (Rosetta)
├── to_release/                          # Upload your ZIPs here (optional)
└── README.md                          # This file
```

## 🔧 Local Development

You can also run the scripts locally on macOS:

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Build universal bundle
./scripts/create_universal_from_zips.sh osx-arm64.zip osx-x64.zip NicFW880_RMS

# Create DMG
./scripts/create_dmg.sh NicFW880_RMS.app NicFW880_RMS-v1.0.0
```

### Temporary stopgap: x86_64-only app for Rosetta

Until upstream arm64 artifacts are corrected (some arm zip dylibs are actually x86_64), ship an x86_64-only app that runs on Apple Silicon via Rosetta:

```bash
./scripts/create_x64_app_from_zip.sh to_release/osx-x64.zip NicFW880_RMS
./scripts/create_dmg.sh NicFW880_RMS.app
```

Notes:
- Root cause (for upstream): the `osx-arm64.zip` includes at least one native dylib compiled as x86_64 (e.g., `libAvaloniaNative.dylib`), which causes arm64 launch to fail. Once fixed, return to the universal script above.

### GitHub Actions: also upload x86_64 artifact

To publish a Rosetta-compatible asset alongside the universal build, add a step (or job) that runs:

```bash
./scripts/create_x64_app_from_zip.sh to_release/osx-x64.zip NicFW880_RMS
./scripts/create_dmg.sh NicFW880_RMS.app
```

Then upload `NicFW880_RMS.dmg` as an additional release asset in your workflow (duplicate the existing upload step and point it at the x86_64 DMG).

## 🎯 Use Cases

- **Windows developers** building for macOS
- **Automated releases** from CI/CD
- **Universal binaries** from separate architecture builds
- **Professional distribution** with installer DMGs

## 📝 Notes

- GitHub Actions provides macOS runners with all necessary tools
- DMG layout is automatically configured for professional appearance
- Creates both individual files and GitHub releases

---

Built with ❤️ and GitHub Actions 🤖
