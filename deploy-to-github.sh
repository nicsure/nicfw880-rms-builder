#!/bin/bash

# Script to upload everything to GitHub repository
# Usage: ./deploy-to-github.sh <repository_url>

set -e

if [ $# -ne 1 ]; then
    echo "Usage: $0 <repository_url>"
    echo "Example: $0 https://github.com/username/nicfw880-rms-builder.git"
    exit 1
fi

REPO_URL="$1"

echo "🚀 Deploying to GitHub..."
echo "📁 Repository: $REPO_URL"

# Verify we are in the correct directory
if [ ! -f ".github/workflows/build-macos.yml" ]; then
    echo "❌ Error: Workflow not found. Are you in the correct directory?"
    exit 1
fi

# Initialize git if it doesn't exist
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    git branch -M main
fi

# Add remote if it doesn't exist
if ! git remote get-url origin >/dev/null 2>&1; then
    echo "🔗 Adding remote origin..."
    git remote add origin "$REPO_URL"
fi

echo "📝 Adding files..."
git add .

echo "💾 Making commit..."
git commit -m "Initial setup: macOS universal bundle builder

- Added GitHub Actions workflow for automated builds
- Added scripts for universal bundle creation
- Added DMG creation with professional layout
- Added comprehensive README with usage instructions

Features:
✅ Universal binary creation (ARM64 + x86_64)
✅ Professional DMG installer
✅ Automatic GitHub releases
✅ Windows-friendly workflow (no local macOS needed)"

echo "📤 Pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ Successfully deployed!"
echo ""
echo "🎯 Next steps:"
echo "   1. Go to your repository: ${REPO_URL%.git}"
echo "   2. Go to 'Actions' tab"
echo "   3. Click on 'Build macOS Universal Bundle'"
echo "   4. Click on 'Run workflow'"
echo "   5. Fill the form with your ZIPs and execute"
echo ""
echo "📋 To use:"
echo "   • Version: v1.0.0"
echo "   • ARM64 ZIP URL: https://example.com/osx-arm64.zip"
echo "   • x64 ZIP URL: https://example.com/osx-x64.zip"
echo "   • Executable name: NicFW880_RMS"
echo "   • Create release: ✅"