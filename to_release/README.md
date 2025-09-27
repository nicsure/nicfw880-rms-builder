# Release Files

Place your ZIP files here for the build pipeline:

- `osx-arm64.zip` - ARM64 macOS build
- `osx-x64.zip` - x86_64 macOS build

The GitHub Actions workflow will automatically use these files to create universal bundles.

## File naming convention
- Files must be named exactly `osx-arm64.zip` and `osx-x64.zip`
- Each ZIP should contain the macOS application bundle ready for packaging