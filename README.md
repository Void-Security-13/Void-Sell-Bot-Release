# Void Bot

ربات فروشگاهی تلگرام برای فروش سرویس با اتصال به پنل‌های مدیریت VPN.

این ریپو شامل نسخه‌ی **آماده‌ی اجرا (کامپایل‌شده)** ربات است — فایل‌های `.so` به‌جای سورس پایتون. نصب یا اجرای این ربات نیازی به سورس اصلی ندارد.

## نصب

روی سرور خودتون (Ubuntu/Debian با دسترسی sudo):

```bash
git clone https://github.com/Void-Security-13/Void-Sell-Bot-Release.git
cd Void-Sell-Bot-Release
bash install.sh
```

موقع اجرا، اسکریپت این اطلاعات رو از شما می‌پرسه:
- توکن ربات (BOT_TOKEN)
- آیدی عددی ادمین (ADMIN_IDS)
- نام فروشگاه
- اطلاعات اتصال به پنل (SANAEI_PANEL_URL, SANAEI_API_TOKEN, SANAEI_SUBSCRIPTION_BASE)
- کد لایسنس (LICENSE_KEY) — مخصوص IP همین سرور، از فروشنده دریافت کنید

بعد از وارد کردن این مقادیر، نصب به‌صورت کامل خودکار انجام می‌شه و ربات به‌عنوان سرویس systemd نصب و اجرا می‌شه (۲۴ ساعته آنلاین، با ری‌استارت خودکار در صورت قطعی).

## مدیریت بعد از نصب

```bash
cd Void-Sell-Bot-Release
sudo systemctl status void-bot      # بررسی وضعیت
sudo systemctl restart void-bot     # ری‌استارت
sudo journalctl -u void-bot -f      # مشاهده‌ی لاگ زنده
```

برای تغییر تنظیمات (توکن، آیدی ادمین و غیره)، فایل `.env` رو ویرایش کنید و سرویس رو ری‌استارت کنید:
```bash
nano .env
sudo systemctl restart void-bot
```

## پشتیبانی

برای دریافت کد لایسنس یا سوالات نصب، با فروشنده تماس بگیرید.
