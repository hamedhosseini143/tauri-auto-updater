# Scripts Directory

این دایرکتوری شامل اسکریپت‌های کمکی برای مدیریت release و deployment است.

## 📜 اسکریپت‌های موجود

### `release-prod.sh` - Production Release Script

اسکریپت خودکار برای ساخت و انتشار نسخه‌های production.

#### استفاده:

```bash
./scripts/release-prod.sh
```

#### پیش‌نیازها:

1. ✅ باید روی branch `main` باشید
2. ✅ Working directory باید clean باشد (بدون تغییرات uncommitted)
3. ✅ `jq` باید نصب باشد:
   ```bash
   brew install jq
   ```

#### فرآیند کار:

1. **بررسی پیش‌نیازها**
   - نصب بودن `jq` و `git`
   - وجود فایل `tauri.conf.json`
   - بودن در git repository

2. **بررسی وضعیت Git**
   - تأیید branch فعلی (باید `main` باشد)
   - بررسی clean بودن working directory

3. **دریافت آخرین تغییرات**
   - Pull کردن آخرین changes از `main`

4. **محاسبه نسخه جدید**
   - دریافت آخرین tag production
   - نمایش منوی انتخاب نوع increment:
     - `Patch (x.x.1)`: رفع باگ‌ها و تغییرات جزئی
     - `Minor (x.1.0)`: ویژگی‌های جدید (backward compatible)
     - `Major (1.0.0)`: تغییرات بزرگ (breaking changes)

5. **تأیید Release**
   - نمایش اطلاعات کامل release
   - درخواست تأیید نهایی از کاربر

6. **آپدیت و Commit**
   - آپدیت `src-tauri/tauri.conf.json` با version جدید
   - Commit کردن تغییرات
   - Push کردن به `main`

7. **ساخت و Push کردن Tag**
   - ساخت tag جدید با فرمت `v{version}`
   - Push کردن tag به GitHub

8. **Trigger کردن GitHub Actions**
   - با push شدن tag، workflow به صورت خودکار اجرا می‌شود

#### مثال اجرا:

```bash
$ ./scripts/release-prod.sh

============================================
🚀 Tauri Auto-Updater Production Release
============================================

============================================
بررسی پیش‌نیازها
============================================

✅ jq نصب شده است
✅ git نصب شده است
✅ در git repository هستیم
✅ فایل Tauri config پیدا شد

============================================
بررسی وضعیت Git
============================================

✅ روی branch 'main' هستید
✅ Working directory clean است

============================================
دریافت آخرین تغییرات
============================================

ℹ️  در حال pull کردن از main ...
✅ آخرین تغییرات دریافت شد

ℹ️  نسخه فعلی در config: 0.1.0
ℹ️  آخرین tag production: v0.1.0

============================================
انتخاب نوع Version Increment
============================================

نوع تغییرات این release را انتخاب کنید:

1) Patch (x.x.1) - رفع باگ‌ها و تغییرات جزئی
2) Minor (x.1.0) - ویژگی‌های جدید (backward compatible)
3) Major (1.0.0) - تغییرات بزرگ (breaking changes)

انتخاب شما [1-3]: 2

✅ نسخه جدید محاسبه شد: v0.2.0

============================================
تأیید Production Release
============================================

⚠️  شما در حال ساخت یک PRODUCTION RELEASE هستید!

اطلاعات Release:
  • Branch: main
  • نسخه فعلی: v0.1.0
  • نسخه جدید: v0.2.0
  • نوع: minor
  • Tag: v0.2.0

این عملیات:
  1. Version در src-tauri/tauri.conf.json را به 0.2.0 تغییر می‌دهد
  2. تغییرات را commit می‌کند
  3. Tag v0.2.0 را ایجاد می‌کند
  4. تغییرات و tag را به GitHub push می‌کند
  5. GitHub Actions workflow را trigger می‌کند

آیا مطمئن هستید که می‌خواهید ادامه دهید؟ (yes/no): yes

ℹ️  در حال آپدیت src-tauri/tauri.conf.json ...
✅ Version در src-tauri/tauri.conf.json به 0.2.0 آپدیت شد

============================================
Commit و Push تغییرات
============================================

ℹ️  در حال commit کردن تغییرات ...
ℹ️  در حال push کردن به main ...
✅ تغییرات commit و push شدند

============================================
ساخت و Push کردن Tag
============================================

ℹ️  در حال ساخت tag v0.2.0 ...
ℹ️  در حال push کردن tag به GitHub ...
✅ Tag v0.2.0 ساخته و push شد

============================================
✅ Release موفقیت‌آمیز بود!
============================================

🎉 نسخه v0.2.0 با موفقیت release شد!

مراحل بعدی:
  1. GitHub Actions workflow به طور خودکار شروع خواهد شد
  2. برنامه برای تمام پلتفرم‌ها build خواهد شد
  3. Release در GitHub ایجاد خواهد شد (به صورت draft)
  4. به این آدرس بروید تا release را publish کنید:
     https://github.com/hamedhosseini143/tauri-auto-updater/releases

ℹ️  منتظر بمانید تا GitHub Actions workflow تمام شود (~5-10 دقیقه)
```

#### الگوی Tag:

Tags با فرمت semantic versioning ساخته می‌شوند:

- `v1.0.0` - Major release اول
- `v1.0.1` - Patch release
- `v1.1.0` - Minor release
- `v2.0.0` - Major release دوم

#### نکات مهم:

⚠️ **هشدارهای امنیتی:**

- این اسکریپت مستقیماً به `main` push می‌کند
- قبل از اجرا حتماً مطمئن شوید که تغییرات شما تست شده است
- از تأیید نهایی (`yes`) با احتیاط استفاده کنید

✅ **بهترین روش‌ها:**

- قبل از release، تمام تست‌ها را اجرا کنید
- مطمئن شوید که `CHANGELOG.md` آپدیت شده است
- از branch feature برای توسعه استفاده کنید، نه مستقیماً روی `main`

🔧 **عیب‌یابی:**

اگر اسکریپت با خطا مواجه شد:

1. **"jq نصب نیست"**

   ```bash
   brew install jq
   ```

2. **"شما روی branch 'feature-xxx' هستید"**

   ```bash
   git checkout main
   ```

3. **"Working directory clean نیست"**

   ```bash
   git status
   git add .
   git commit -m "commit message"
   # یا
   git stash
   ```

4. **"Tag قبلاً وجود دارد"**
   - اگر می‌خواهید tag را دوباره بسازید:
   ```bash
   git tag -d v1.0.0
   git push origin :refs/tags/v1.0.0
   ```

## 🔗 مستندات مرتبط

- راهنمای کامل Auto-Updater: [../UPDATER_SETUP.md](../UPDATER_SETUP.md)
- GitHub Workflow: [../.github/workflows/publish.yml](../.github/workflows/publish.yml)

## 📝 لاگ تغییرات

برای مشاهده تاریخچه کامل تغییرات، به فایل `CHANGELOG.md` مراجعه کنید.
