#!/usr/bin/env bash
# نصب‌کننده‌ی عمومی Void Bot.
# این اسکریپت خودش سورسی نداره؛ سورس اصلی رو مخفیانه از ریپوی خصوصی
# می‌کشه، نصب و کامپایل می‌کنه، و در آخر فایل‌های خام پایتون رو حذف می‌کنه.
# مشتری فقط همین یه فایل رو اجرا می‌کنه:
#   bash get-void-bot.sh
set -euo pipefail

PRIVATE_REPO="Void-Security-13/Void-Sell-Bot"
INSTALL_DIR="$HOME/void-bot"

echo "=============================================="
echo " Void Bot - نصب"
echo "=============================================="
echo ""
echo "برای نصب باید توکن دسترسی‌ای که از فروشنده گرفتید رو وارد کنید."
read -r -p "Access Token: " ACCESS_TOKEN
while [ -z "$ACCESS_TOKEN" ]; do
    read -r -p "این مورد اجباریه. Access Token رو وارد کنید: " ACCESS_TOKEN
done

if [ -d "$INSTALL_DIR" ]; then
    echo "پوشه‌ی $INSTALL_DIR از قبل وجود داره."
    read -r -p "پاک و از نو کلون بشه؟ [y/N] " REDO
    if [[ "$REDO" =~ ^[Yy]$ ]]; then
        rm -rf "$INSTALL_DIR"
    else
        echo "لغو شد."
        exit 1
    fi
fi

echo "در حال دریافت فایل‌های نصب..."
if ! git clone --quiet "https://${ACCESS_TOKEN}@github.com/${PRIVATE_REPO}.git" "$INSTALL_DIR" 2>/tmp/clone_err.log; then
    echo "دریافت فایل‌ها ناموفق بود. توکن یا دسترسی رو بررسی کنید."
    cat /tmp/clone_err.log
    rm -f /tmp/clone_err.log
    exit 1
fi
rm -f /tmp/clone_err.log

# دیگه به تاریخچه‌ی گیت این کلون نیازی نیست و شامل توکن توی remote URL هم هست؛
# کاملاً حذفش می‌کنیم تا هیچ ردی از توکن یا سورس روی دیسک با گیت قابل ردیابی نمونه.
rm -rf "$INSTALL_DIR/.git"

cd "$INSTALL_DIR"
if [ ! -f "install.sh" ]; then
    echo "install.sh پیدا نشد. با پشتیبانی تماس بگیرید."
    exit 1
fi

echo ""
echo "در حال نصب و کامپایل..."
bash install.sh

echo ""
echo "نصب تمام شد. ربات از پوشه‌ی ${INSTALL_DIR} در حال اجراست."
echo "برای مدیریت بعدی:"
echo "  cd ${INSTALL_DIR} && bash void-bot.sh"
