# Tauri Auto-Updater Setup Guide

This project is configured with Tauri's auto-updater feature. Follow these steps to complete the setup.

## Prerequisites

✅ Auto-updater plugin installed
✅ Signing keys generated
✅ GitHub Actions workflow created
✅ Frontend code implemented

## Required GitHub Secrets

To enable the auto-updater, you need to add the following secrets to your GitHub repository:

### 1. TAURI_SIGNING_PRIVATE_KEY

This is your private signing key. To get its value:

```bash
cat ~/.tauri/auto_updater.key
```

Copy the entire content and add it as a GitHub secret:

1. Go to your repository on GitHub
2. Click on **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `TAURI_SIGNING_PRIVATE_KEY`
5. Value: Paste the private key content
6. Click **Add secret**

### 2. TAURI_SIGNING_PRIVATE_KEY_PASSWORD

This is the password you used when generating the keys. If you used an empty password (pressed Enter), use an empty string:

1. In GitHub repository **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Name: `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`
4. Value: Your password (or leave empty if no password was set)
5. Click **Add secret**

## GitHub Actions Permissions

Make sure GitHub Actions has write permissions:

1. Go to your repository **Settings** → **Actions** → **General**
2. Scroll down to **Workflow permissions**
3. Select **Read and write permissions**
4. Click **Save**

## How to Release a New Version

### Automatic Release (Recommended)

استفاده از اسکریپت خودکار:

```bash
./scripts/release-prod.sh
```

این اسکریپت:

- ✅ تمام بررسی‌های لازم را انجام می‌دهد
- ✅ Version را آپدیت می‌کند
- ✅ Tag می‌زند و به GitHub push می‌کند
- ✅ GitHub Actions را trigger می‌کند

**پیش‌نیاز:** نصب `jq`:

```bash
brew install jq
```

برای جزئیات بیشتر: [scripts/README.md](scripts/README.md)

### Manual Release

#### Option 1: Create and Push Tag

```bash
# آپدیت version در src-tauri/tauri.conf.json
# سپس:
git add src-tauri/tauri.conf.json
git commit -m "chore: bump version to 1.0.0"
git push origin main
git tag v1.0.0
git push origin v1.0.0
```

#### Option 2: Manual Workflow Dispatch

1. Go to **Actions** tab in your GitHub repository
2. Select the **publish** workflow
3. Click **Run workflow**
4. Select the branch and click **Run workflow**

## Testing the Auto-Updater

1. First, create an initial release:
   - Update version in `src-tauri/tauri.conf.json` (e.g., "0.1.0")
   - Push to `release` branch or manually run the workflow
   - Wait for the workflow to complete
   - Publish the draft release on GitHub

2. Build and run the current version locally:

   ```bash
   npm run tauri build
   ```

3. Create a new version:
   - Update version in `src-tauri/tauri.conf.json` (e.g., "0.2.0")
   - Push to `release` branch or manually run the workflow
   - Publish the new release on GitHub

4. Run the previously built app (version 0.1.0)
   - The app should automatically check for updates on startup
   - If a new version is available, it will download and install it
   - After installation, the app will restart with the new version

## Configuration Details

### Updater Endpoint

The updater checks for updates at:

```
https://github.com/hamedhosseini143/tauri-auto-updater/releases/latest/download/latest.json
```

This endpoint is automatically created by the GitHub Actions workflow (tauri-action).

### Updater Config Location

`src-tauri/tauri.conf.json`:

```json
{
  "plugins": {
    "updater": {
      "endpoints": ["..."],
      "pubkey": "..."
    }
  }
}
```

### Build Artifacts

The workflow will create updater artifacts for:

- **macOS**: `.app.tar.gz` (both Intel and Apple Silicon)
- **Linux**: `.AppImage.tar.gz`
- **Windows**: `.nsis.zip` and `.msi.zip`

These artifacts are automatically signed and include signature files (`.sig`).

## Troubleshooting

### "Resource not accessible by integration" error

- Go to repository **Settings** → **Actions** → **General** → **Workflow permissions**
- Enable **Read and write permissions**

### Update not detected

- Make sure you've published the GitHub release (not just a draft)
- Check that the version in `tauri.conf.json` is higher than the current version
- Verify the updater endpoint URL is correct
- Check browser console for errors

### Invalid signature error

- Ensure `TAURI_SIGNING_PRIVATE_KEY` secret contains the correct private key
- Verify the public key in `tauri.conf.json` matches the generated public key
- Make sure the private key password is correct in the secret

## Key Files

- **Rust plugin init**: `src-tauri/src/lib.rs`
- **Frontend updater code**: `src/App.tsx`
- **Tauri config**: `src-tauri/tauri.conf.json`
- **GitHub workflow**: `.github/workflows/publish.yml`
- **Public key**: `~/.tauri/auto_updater.key.pub`
- **Private key**: `~/.tauri/auto_updater.key` (keep this secure!)

## Additional Resources

- [Tauri Updater Plugin Documentation](https://v2.tauri.app/plugin/updater/)
- [Tauri GitHub Actions Documentation](https://v2.tauri.app/distribute/pipelines/github/)
- [tauri-action Repository](https://github.com/tauri-apps/tauri-action)

## Security Notes

⚠️ **Important**:

- Never commit your private key (`~/.tauri/auto_updater.key`) to version control
- Keep your `TAURI_SIGNING_PRIVATE_KEY` secret secure
- Only add the public key to your repository
- The `.gitignore` should exclude any `.key` files
