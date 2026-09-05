#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"
SERVICE_NAME="void-bot"
PYTHON_BIN="python3"

if command -v apt-get >/dev/null 2>&1; then
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -y
    sudo apt-get install -y python3 python3-pip python3-venv curl
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y python3 python3-pip curl
elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y python3 python3-pip curl
else
    echo "مدیر پکیج شناخته‌شده‌ای پیدا نشد. python3, python3-venv, python3-pip رو دستی نصب کنید."
    exit 1
fi

if ! command -v "$PYTHON_BIN" >/dev/null 2>&1; then
    echo "نصب python3 ناموفق بود."
    exit 1
fi

if [ ! -d "venv" ]; then
    if ! "$PYTHON_BIN" -m venv venv; then
        sudo apt-get install -y python3-venv || true
        "$PYTHON_BIN" -m venv venv
    fi
fi
# shellcheck disable=SC1091
source venv/bin/activate
pip install --upgrade pip >/dev/null
pip install -r requirements.txt >/dev/null

if [ -f ".env" ]; then
    read -r -p "فایل .env از قبل وجود داره. دوباره ساخته بشه؟ [y/N] " REBUILD_ENV
    REBUILD_ENV=${REBUILD_ENV:-N}
else
    REBUILD_ENV="y"
fi

if [[ "$REBUILD_ENV" =~ ^[Yy]$ ]]; then
    read -r -p "توکن ربات (BOT_TOKEN): " BOT_TOKEN
    while [ -z "$BOT_TOKEN" ]; do
        read -r -p "توکن ربات (BOT_TOKEN): " BOT_TOKEN
    done

    read -r -p "آیدی عددی ادمین (ADMIN_IDS): " ADMIN_IDS
    while [ -z "$ADMIN_IDS" ]; do
        read -r -p "آیدی عددی ادمین (ADMIN_IDS): " ADMIN_IDS
    done

    read -r -p "یوزرنیم کانال عضویت اجباری (بدون @، اختیاری): " FORCE_JOIN_CHANNEL

    read -r -p "نام فروشگاه (SHOP_NAME): " SHOP_NAME
    while [ -z "$SHOP_NAME" ]; do
        read -r -p "نام فروشگاه (SHOP_NAME): " SHOP_NAME
    done

    DB_PATH="void_bot.db"

    read -r -p "VIRTUALIZOR_BASE_URL (اختیاری): " VIRTUALIZOR_BASE_URL
    read -r -p "VIRTUALIZOR_API_KEY (اختیاری): " VIRTUALIZOR_API_KEY
    read -r -p "VIRTUALIZOR_API_PASS (اختیاری): " VIRTUALIZOR_API_PASS

    read -r -p "SANAEI_PANEL_URL: " SANAEI_PANEL_URL
    while [ -z "$SANAEI_PANEL_URL" ]; do
        read -r -p "SANAEI_PANEL_URL: " SANAEI_PANEL_URL
    done

    read -r -p "SANAEI_API_TOKEN: " SANAEI_API_TOKEN
    while [ -z "$SANAEI_API_TOKEN" ]; do
        read -r -p "SANAEI_API_TOKEN: " SANAEI_API_TOKEN
    done

    read -r -p "SANAEI_SUBSCRIPTION_BASE: " SANAEI_SUBSCRIPTION_BASE
    while [ -z "$SANAEI_SUBSCRIPTION_BASE" ]; do
        read -r -p "SANAEI_SUBSCRIPTION_BASE: " SANAEI_SUBSCRIPTION_BASE
    done

    read -r -p "کد لایسنس (LICENSE_KEY): " LICENSE_KEY
    while [ -z "$LICENSE_KEY" ]; do
        read -r -p "کد لایسنس (LICENSE_KEY): " LICENSE_KEY
    done

    cat > .env <<EOF
BOT_TOKEN=${BOT_TOKEN}
SHOP_NAME=${SHOP_NAME}
ADMIN_IDS=${ADMIN_IDS}
FORCE_JOIN_CHANNEL=${FORCE_JOIN_CHANNEL}
DB_PATH=${DB_PATH}

VIRTUALIZOR_BASE_URL=${VIRTUALIZOR_BASE_URL}
VIRTUALIZOR_API_KEY=${VIRTUALIZOR_API_KEY}
VIRTUALIZOR_API_PASS=${VIRTUALIZOR_API_PASS}

SANAEI_PANEL_URL=${SANAEI_PANEL_URL}
SANAEI_API_TOKEN=${SANAEI_API_TOKEN}
SANAEI_SUBSCRIPTION_BASE=${SANAEI_SUBSCRIPTION_BASE}

LICENSE_KEY=${LICENSE_KEY}
EOF
    chmod 600 .env

    echo ""
    echo "BOT_TOKEN=${BOT_TOKEN}"
    echo "SHOP_NAME=${SHOP_NAME}"
    echo "ADMIN_IDS=${ADMIN_IDS}"
    echo "FORCE_JOIN_CHANNEL=${FORCE_JOIN_CHANNEL}"
    echo "DB_PATH=${DB_PATH}"
    echo "VIRTUALIZOR_BASE_URL=${VIRTUALIZOR_BASE_URL}"
    echo "VIRTUALIZOR_API_KEY=${VIRTUALIZOR_API_KEY}"
    echo "VIRTUALIZOR_API_PASS=${VIRTUALIZOR_API_PASS}"
    echo "SANAEI_PANEL_URL=${SANAEI_PANEL_URL}"
    echo "SANAEI_API_TOKEN=${SANAEI_API_TOKEN}"
    echo "SANAEI_SUBSCRIPTION_BASE=${SANAEI_SUBSCRIPTION_BASE}"
    echo "LICENSE_KEY=${LICENSE_KEY}"
fi

ENTRY_FILE="main.py"

echo ""
echo "در حال راه‌اندازی ربات به‌صورت سرویس systemd (اجرای ۲۴ ساعته و ری‌استارت خودکار)..."

if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi
CURRENT_USER=$(whoami)
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

$SUDO tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=Telegram Shop Bot
After=network.target

[Service]
Type=simple
User=${CURRENT_USER}
WorkingDirectory=${REPO_DIR}
EnvironmentFile=${REPO_DIR}/.env
ExecStart=${REPO_DIR}/venv/bin/python ${REPO_DIR}/${ENTRY_FILE}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

$SUDO systemctl daemon-reload
$SUDO systemctl enable "$SERVICE_NAME"
$SUDO systemctl restart "$SERVICE_NAME"

echo ""
echo "نصب تمام شد. ربات به‌صورت سرویس '${SERVICE_NAME}' از پوشه‌ی ${REPO_DIR} در حال اجراست و ۲۴ ساعته آنلاین می‌مونه."
echo "بررسی وضعیت:   sudo systemctl status ${SERVICE_NAME}"
echo "دیدن لاگ‌ها:     sudo journalctl -u ${SERVICE_NAME} -f"
