# 🚀 راهنمای سریع شروع کار با Auto-Updater

این راهنمای گام به گام برای راه‌اندازی سریع auto-updater است.

## ✅ Checklist راه‌اندازی

- [ ] نصب dependencies
- [ ] افزودن GitHub Secrets
- [ ] فعال‌سازی GitHub Actions permissions
- [ ] اولین release
- [ ] تست updater

## 📝 مرحله ۱: نصب Dependencies

```bash
# نصب Node dependencies
npm install

# نصب jq (برای macOS)
brew install jq

# تست build
npm run tauri build
```

## 🔑 مرحله ۲: افزودن GitHub Secrets

### ۲.۱ دریافت کلید خصوصی

```bash
./get-private-key.sh
```

یا:

```bash
cat ~/.tauri/auto_updater.key
```

### ۲.۲ افزودن به GitHub

1. به مخزن خود در GitHub بروید
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** را کلیک کنید

**Secret اول:**

- Name: `TAURI_SIGNING_PRIVATE_KEY`
- Value: محتوای کلید خصوصی (از دستور بالا)

**Secret دوم:**

- Name: `TAURI_SIGNING_PRIVATE_KEY_PASSWORD`
- Value: رمز عبور کلید (اگر هنگام ساخت رمز ندادید، خالی بگذارید)

## ⚙️ مرحله ۳: فعال‌سازی GitHub Actions Permissions

1. **Settings** → **Actions** → **General**
2. پایین صفحه، بخش **Workflow permissions**
3. **Read and write permissions** را انتخاب کنید
4. **Save** را کلیک کنید

## 🎯 مرحله ۴: اولین Release

### روش ۱: استفاده از اسکریپت (توصیه می‌شود)

```bash
./scripts/release-prod.sh
```

خروجی:

```
============================================
🚀 Tauri Auto-Updater Production Release
============================================

...

نوع تغییرات این release را انتخاب کنید:

1) Patch (x.x.1) - رفع باگ‌ها و تغییرات جزئی
2) Minor (x.1.0) - ویژگی‌های جدید (backward compatible)
3) Major (1.0.0) - تغییرات بزرگ (breaking changes)

انتخاب شما [1-3]: 1
```

برای اولین release، گزینه `1` (Patch) را انتخاب کنید.

### روش ۲: دستی

```bash
# آپدیت version در src-tauri/tauri.conf.json به 0.1.0
git add src-tauri/tauri.conf.json
git commit -m "chore: bump version to 0.1.0"
git push origin main
git tag v0.1.0
git push origin v0.1.0
```

## 👀 مرحله ۵: مانیتور کردن GitHub Actions

1. به تب **Actions** در مخزن GitHub بروید
2. یک workflow با نام **publish** باید در حال اجرا باشد
3. منتظر بمانید تا workflow تمام شود (~5-10 دقیقه)
4. اگر موفقیت‌آمیز بود، یک چک مارک سبز نشان می‌دهد

## 📦 مرحله ۶: Publish کردن Release

1. به **Releases** در GitHub بروید
2. یک draft release با نام `Auto Updater v0.1.0` باید وجود داشته باشد
3. روی release کلیک کنید
4. **Edit** را کلیک کنید
5. می‌توانید Release notes را ویرایش کنید
6. **Publish release** را کلیک کنید

✅ اولین release شما منتشر شد!

## 🧪 مرحله ۷: تست Auto-Updater

### ۷.۱ Build نسخه فعلی

```bash
npm run tauri build
```

فایل build شده را پیدا کنید:

- **macOS**: `src-tauri/target/release/bundle/macos/auto_updater.app`
- **Windows**: `src-tauri/target/release/bundle/nsis/auto_updater_0.1.0_x64-setup.exe`
- **Linux**: `src-tauri/target/release/bundle/appimage/auto_updater_0.1.0_amd64.AppImage`

برنامه را اجرا کنید و اطمینان حاصل کنید که کار می‌کند.

### ۷.۲ ساخت نسخه دوم

```bash
./scripts/release-prod.sh
```

این بار version به `0.1.1` یا `0.2.0` می‌رود (بسته به انتخاب شما).

منتظر بمانید تا GitHub Actions تمام شود و release را publish کنید.

### ۷.۳ تست Update

1. نسخه قدیمی (0.1.0) را اجرا کنید
2. برنامه باید به طور خودکار چک کند و پیام بدهد:
   ```
   Update available: 0.1.1. Current version: 0.1.0
   Downloading update...
   ```
3. دانلود و نصب خودکار
4. برنامه restart می‌شود با نسخه جدید

✅ Auto-updater شما کار می‌کند!

## 🎉 تمام شد!

حالا شما:

- ✅ Auto-updater کاملاً راه‌اندازی شده دارید
- ✅ یک workflow خودکار برای release
- ✅ امضای دیجیتال برای امنیت

## 🚀 مراحل بعدی

### برای هر Release جدید:

```bash
# فقط این یک دستور!
./scripts/release-prod.sh
```

### سفارشی‌سازی

- **تغییر UI Updater**: ویرایش [src/App.tsx](src/App.tsx)
- **تغییر تنظیمات Updater**: ویرایش [src-tauri/tauri.conf.json](src-tauri/tauri.conf.json)
- **تغییر Workflow**: ویرایش [.github/workflows/publish.yml](.github/workflows/publish.yml)

## 📚 مستندات بیشتر

- [راهنمای کامل Auto-Updater](UPDATER_SETUP.md)
- [مستندات Scripts](scripts/README.md)
- [README اصلی](README.md)

## ❓ سوالات متداول

### ۱. چگونه version را تغییر دهم؟

از اسکریپت استفاده کنید:

```bash
./scripts/release-prod.sh
```

### ۲. چگونه release را لغو کنم؟

اگر tag را هنوز push نکردید:

```bash
git tag -d v0.1.0
```

اگر push کردید:

```bash
git tag -d v0.1.0
git push origin :refs/tags/v0.1.0
```

### ۳. چگونه release قدیمی را حذف کنم؟

از صفحه Releases در GitHub، روی release کلیک کنید و **Delete** را انتخاب کنید.

### ۴. Updater کار نمی‌کند!

بررسی کنید:

- [ ] Release منتشر شده (نه draft)
- [ ] Version در config بیشتر از version فعلی است
- [ ] Public key در config درست است
- [ ] Endpoint URL درست است
- [ ] اتصال اینترنت برقرار است

### ۵. GitHub Actions شکست خورد!

بررسی کنید:

- [ ] Secrets درست اضافه شده‌اند
- [ ] Workflow permissions فعال است
- [ ] لاگ‌های workflow را بخوانید

## 🆘 کمک بیشتر

اگر مشکلی دارید:

1. [Troubleshooting در UPDATER_SETUP.md](UPDATER_SETUP.md#troubleshooting) را بخوانید
2. یک [Issue در GitHub](https://github.com/hamedhosseini143/tauri-auto-updater/issues) باز کنید

---

موفق باشید! 🎊
