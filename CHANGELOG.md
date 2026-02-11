# Changelog

تمام تغییرات قابل توجه در این پروژه در این فایل مستند می‌شود.

این فایل از قالب [Keep a Changelog](https://keepachangelog.com/fa/1.0.0/) پیروی می‌کند
و این پروژه از [Semantic Versioning](https://semver.org/lang/fa/) استفاده می‌کند.

## [Unreleased]

### راه‌اندازی اولیه پروژه

#### Added
- 🎉 راه‌اندازی کامل Tauri Auto-Updater
- ✅ نصب و پیکربندی `tauri-plugin-updater`
- ✅ نصب `@tauri-apps/plugin-updater` برای frontend
- ✅ پیکربندی `tauri.conf.json` برای updater
  - افزودن `createUpdaterArtifacts: true`
  - تنظیم endpoint GitHub
  - افزودن کلید عمومی (pubkey)
- ✅ راه‌اندازی plugin در Rust code ([src-tauri/src/lib.rs](src-tauri/src/lib.rs))
- ✅ پیاده‌سازی UI کامل برای updater در React ([src/App.tsx](src/App.tsx))
  - چک خودکار هنگام باز شدن برنامه
  - نمایش وضعیت دانلود
  - نمایش progress bar
  - دکمه دستی برای چک کردن آپدیت
- ✅ GitHub Actions Workflow ([.github/workflows/publish.yml](.github/workflows/publish.yml))
  - Build برای macOS (Intel + Apple Silicon)
  - Build برای Windows
  - Build برای Linux
  - امضای خودکار artifacts
  - ایجاد خودکار `latest.json`
  - Trigger با push کردن tag (فرمت: `v*`)
- ✅ ساخت کلیدهای امضای دیجیتال
  - کلید عمومی و خصوصی در `~/.tauri/auto_updater.key`
  - افزودن کلید عمومی به config
- ✅ اسکریپت خودکار برای production release ([scripts/release-prod.sh](scripts/release-prod.sh))
  - بررسی پیش‌نیازها
  - بررسی branch و working directory
  - Pull آخرین تغییرات
  - انتخاب نوع version increment (patch/minor/major)
  - آپدیت خودکار `tauri.conf.json`
  - Commit و push خودکار
  - ساخت و push tag
  - UI رنگی و کاربرپسند
- ✅ مستندات کامل
  - [README.md](README.md): معرفی کامل پروژه
  - [UPDATER_SETUP.md](UPDATER_SETUP.md): راهنمای جامع setup
  - [QUICK_START.md](QUICK_START.md): راهنمای سریع شروع
  - [scripts/README.md](scripts/README.md): مستندات اسکریپت‌ها
- ✅ اسکریپت‌های کمکی
  - [get-private-key.sh](get-private-key.sh): دریافت کلید خصوصی برای GitHub Secrets
  - [scripts/release-prod.sh](scripts/release-prod.sh): release خودکار
- ✅ آپدیت `.gitignore` برای عدم commit شدن کلیدهای امضا

#### Security
- 🔒 پیاده‌سازی امضای دیجیتال برای artifacts
- 🔒 ذخیره امن کلید خصوصی در GitHub Secrets
- 🔒 اضافه کردن `*.key` و `.tauri/` به `.gitignore`

#### Documentation
- 📚 راهنمای گام به گام برای راه‌اندازی
- 📚 مثال‌های کامل استفاده
- 📚 Troubleshooting guide
- 📚 مستندات اسکریپت‌ها
- 📚 FAQ

---

## نحوه نگهداری این Changelog

### انواع تغییرات:

- `Added` برای ویژگی‌های جدید
- `Changed` برای تغییرات در ویژگی‌های موجود
- `Deprecated` برای ویژگی‌هایی که به زودی حذف می‌شوند
- `Removed` برای ویژگی‌های حذف شده
- `Fixed` برای رفع باگ‌ها
- `Security` برای تغییرات امنیتی

### فرمت نسخه:

این پروژه از [Semantic Versioning](https://semver.org/) استفاده می‌کند:

- **MAJOR** version (1.0.0): تغییرات ناسازگار (breaking changes)
- **MINOR** version (0.1.0): ویژگی‌های جدید سازگار با نسخه قبلی
- **PATCH** version (0.0.1): رفع باگ‌ها و تغییرات جزئی

---

## قالب برای Release‌های آینده:

```markdown
## [1.0.0] - 2026-02-XX

### Added
- ویژگی جدید اضافه شد

### Changed
- تغییر در ویژگی موجود

### Fixed
- رفع باگ خاص

### Security
- بهبود امنیتی

[1.0.0]: https://github.com/hamedhosseini143/tauri-auto-updater/compare/v0.1.0...v1.0.0
```

---

[Unreleased]: https://github.com/hamedhosseini143/tauri-auto-updater/compare/main...HEAD
