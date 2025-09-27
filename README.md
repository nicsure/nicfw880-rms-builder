# 🍎 macOS Universal Bundle Builder

Automated GitHub Actions workflow to build universal macOS application bundles from ARM64 and x86_64 ZIP files.

## 🚀 How to Use

### Option 1: Manual Trigger (Recommended)

1. Go to **Actions** tab in your GitHub repo
2. Click **Build macOS Universal Bundle**
3. Click **Run workflow**
4. Fill in the form:
   - **Version**: `v1.0.0` (or your version)
   - **ARM64 ZIP URL**: URL or path to your ARM64 ZIP
   - **x64 ZIP URL**: URL or path to your x64 ZIP
   - **Executable name**: `NicFW880_RMS` (your app name)
   - **Create release**: ✅ (to auto-create GitHub release)

### Option 2: Upload ZIPs to Repo

1. Create `releases/` folder in your repo
2. Upload your ZIP files there
3. Use paths like `releases/osx-arm64.zip` in the workflow

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
│   └── create_dmg.sh                  # DMG creation
├── releases/                          # Upload your ZIPs here (optional)
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

## 🎯 Use Cases

- **Windows developers** building for macOS
- **Automated releases** from CI/CD
- **Universal binaries** from separate architecture builds
- **Professional distribution** with installer DMGs

## 📝 Notes

- Requires public URLs for ZIP files OR upload them to the repo
- GitHub Actions provides macOS runners with all necessary tools
- DMG layout is automatically configured for professional appearance
- Creates both individual files and GitHub releases

---

Built with ❤️ and GitHub Actions 🤖