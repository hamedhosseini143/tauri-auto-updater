# 🚀 Tauri Auto-Updater

یک پروژه نمونه کامل برای پیاده‌سازی Auto-Updater در Tauri apps با React و TypeScript.

[![Tauri](https://img.shields.io/badge/Tauri-v2-blue)](https://tauri.app)
[![React](https://img.shields.io/badge/React-19-61DAFB)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.8-blue)](https://www.typescriptlang.org/)

## ✨ ویژگی‌ها

- ✅ **Auto-Updater کامل**: چک خودکار و نصب آپدیت‌ها
- ✅ **GitHub Actions Workflow**: Build و release خودکار برای تمام پلتفرم‌ها
- ✅ **اسکریپت Release خودکار**: ساخت و انتشار نسخه‌های production با یک دستور
- ✅ **امضای دیجیتال**: تأیید اعتبار فایل‌های آپدیت
- ✅ **پشتیبانی Multi-Platform**: macOS (Intel + Apple Silicon), Windows, Linux
- ✅ **UI واکنش‌گرا**: نمایش پیشرفت دانلود و نصب

## 🛠️ تکنولوژی‌ها

- **Frontend**: React 19 + TypeScript + Vite
- **Backend**: Rust + Tauri v2
- **CI/CD**: GitHub Actions
- **Package Manager**: npm/yarn/pnpm

## 📋 پیش‌نیازها

- [Node.js](https://nodejs.org/) (LTS version)
- [Rust](https://www.rust-lang.org/tools/install)
- [Tauri Prerequisites](https://tauri.app/start/prerequisites/)
- `jq` برای اسکریپت release:
  ```bash
  brew install jq  # macOS
  ```

## 🚀 شروع سریع

### 1. نصب Dependencies

```bash
npm install
```

### 2. اجرای برنامه در حالت Development

```bash
npm run tauri dev
```

### 3. Build برنامه

```bash
npm run tauri build
```

## 📦 Release و Deployment

### روش خودکار (توصیه می‌شود)

```bash
./scripts/release-prod.sh
```

این اسکریپت:

1. تمام بررسی‌های لازم را انجام می‌دهد
2. Version را آپدیت می‌کند
3. Tag می‌زند و به GitHub push می‌کند
4. GitHub Actions Workflow را trigger می‌کند

**مراحل:**

- اسکریپت را اجرا کنید: `./scripts/release-prod.sh`
- نوع version increment را انتخاب کنید (patch/minor/major)
- تأیید کنید
- منتظر بمانید تا GitHub Actions build را تمام کند
- به [Releases](https://github.com/hamedhosseini143/tauri-auto-updater/releases) بروید و release را publish کنید

جزئیات بیشتر: [scripts/README.md](scripts/README.md)

### روش دستی

```bash
# 1. آپدیت version در src-tauri/tauri.conf.json
# 2. Commit و push
git add src-tauri/tauri.conf.json
git commit -m "chore: bump version to 1.0.0"
git push origin main

# 3. ساخت و push کردن tag
git tag v1.0.0
git push origin v1.0.0

# 4. GitHub Actions به طور خودکار اجرا می‌شود
```

## 🔧 راه‌اندازی Auto-Updater

### راهنمای کامل Setup

مستندات جامع برای راه‌اندازی auto-updater را در [UPDATER_SETUP.md](UPDATER_SETUP.md) مشاهده کنید.

### خلاصه مراحل اولیه:

1. **افزودن GitHub Secrets:**
   - `TAURI_SIGNING_PRIVATE_KEY`: کلید خصوصی امضا
   - `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`: رمز عبور کلید

2. **فعال‌سازی GitHub Actions Permissions:**
   - Settings → Actions → General
   - Workflow permissions → Read and write permissions

3. **اولین Release:**
   ```bash
   ./scripts/release-prod.sh
   ```

## 📁 ساختار پروژه

```
auto_updater/
├── .github/
│   └── workflows/
│       └── publish.yml          # GitHub Actions workflow
├── scripts/
│   ├── release-prod.sh          # اسکریپت release خودکار
│   └── README.md                # مستندات اسکریپت‌ها
├── src/
│   ├── App.tsx                  # کامپوننت اصلی با updater UI
│   └── ...
├── src-tauri/
│   ├── src/
│   │   └── lib.rs               # کد Rust با plugin updater
│   ├── tauri.conf.json          # تنظیمات Tauri و updater
│   └── Cargo.toml               # Dependencies Rust
├── UPDATER_SETUP.md             # راهنمای جامع setup
├── get-private-key.sh           # اسکریپت کمکی برای دریافت کلید خصوصی
└── README.md                    # این فایل
```

## 🔑 فایل‌های کلیدی

### Frontend

- [src/App.tsx](src/App.tsx): UI برای چک و نصب آپدیت‌ها

### Backend

- [src-tauri/src/lib.rs](src-tauri/src/lib.rs): راه‌اندازی plugin updater
- [src-tauri/tauri.conf.json](src-tauri/tauri.conf.json): تنظیمات updater و bundle

### CI/CD

- [.github/workflows/publish.yml](.github/workflows/publish.yml): Build و release خودکار

### Scripts

- [scripts/release-prod.sh](scripts/release-prod.sh): اسکریپت release خودکار

## 🧪 تست کردن Auto-Updater

1. **ساخت نسخه اول:**

   ```bash
   ./scripts/release-prod.sh
   # انتخاب: patch (اگر version 0.0.0 است، به 0.0.1 می‌رود)
   ```

2. **منتظر بمانید تا GitHub Actions تمام شود**

3. **Release را publish کنید** (از حالت draft خارج کنید)

4. **Build کنید و اجرا کنید:**

   ```bash
   npm run tauri build
   # فایل build شده را اجرا کنید
   ```

5. **ساخت نسخه دوم:**

   ```bash
   ./scripts/release-prod.sh
   # انتخاب: patch (به 0.0.2 می‌رود)
   ```

6. **نسخه قدیمی (0.0.1) را اجرا کنید:**
   - برنامه به طور خودکار نسخه 0.0.2 را تشخیص می‌دهد
   - دانلود و نصب می‌کند
   - برنامه را restart می‌کند

## 📚 مستندات

- [راهنمای جامع Auto-Updater Setup](UPDATER_SETUP.md)
- [مستندات Scripts](scripts/README.md)
- [Tauri Updater Plugin Docs](https://v2.tauri.app/plugin/updater/)
- [GitHub Actions for Tauri](https://v2.tauri.app/distribute/pipelines/github/)

## 🤝 مشارکت

Pull request‌ها و issue‌ها استقبال می‌شوند!

## 📝 لایسنس

این پروژه تحت لایسنس MIT است.

## 🔗 لینک‌های مفید

- [مخزن GitHub](https://github.com/hamedhosseini143/tauri-auto-updater)
- [Releases](https://github.com/hamedhosseini143/tauri-auto-updater/releases)
- [Issues](https://github.com/hamedhosseini143/tauri-auto-updater/issues)

## 💡 نکات

- ⚠️ هرگز کلید خصوصی (`~/.tauri/auto_updater.key`) را commit نکنید
- ✅ قبل از release، تمام تست‌ها را اجرا کنید
- ✅ از semantic versioning استفاده کنید
- ✅ Release notes را در GitHub کامل کنید

## 🐛 عیب‌یابی

برای مشکلات رایج و راه‌حل‌ها، به بخش [Troubleshooting در UPDATER_SETUP.md](UPDATER_SETUP.md#troubleshooting) مراجعه کنید.

---

ساخته شده با ❤️ با Tauri + React + TypeScript
