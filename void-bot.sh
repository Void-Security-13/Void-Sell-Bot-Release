#!/usr/bin/env bash
# منوی مدیریت Void Bot
set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"
SERVICE_NAME="void-bot"
SCRIPT_VERSION="v1.0.0"

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
PINK='\033[0;35m'
RED='\033[0;31m'
NC='\033[0m'

get_ip() {
    curl -s -4 --max-time 5 https://api.ipify.org 2>/dev/null || echo "نامشخص"
}

banner() {
    clear
    echo -e "${GREEN}"
    cat << "EOF"
 __     __       _      _   ____        _
 \ \   / /__ (_) __| | | | __ )  ___ | |_
  \ \ / / _ \| |/ _` | | |  _ \ / _ \| __|
   \ V / (_) | | (_| | | | |_) | (_) | |_
    \_/ \___/|_|\__,_| |_|____/ \___/ \__|
EOF
    echo -e "${NC}"
    echo -e "${CYAN}Script Version:${NC} ${PINK}${SCRIPT_VERSION}${NC}"
    echo -e "${YELLOW}------------------------------------------------------------${NC}"
    echo -e "${CYAN}IPv4:${NC}      ${PINK}$(get_ip)${NC}"
    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        echo -e "${CYAN}وضعیت:${NC}    ${GREEN}در حال اجرا${NC}"
    else
        echo -e "${CYAN}وضعیت:${NC}    ${RED}متوقف${NC}"
    fi
    echo -e "${YELLOW}------------------------------------------------------------${NC}"
    echo ""
    echo -e "  ${GREEN}1.${NC} Run  (نصب / اجرا / راه‌اندازی ربات)"
    echo -e "  ${RED}2.${NC} حذف کامل اسکریپت و ربات از سرور"
    echo -e "  ${CYAN}0.${NC} خروج"
    echo ""
    echo -e "${YELLOW}------------------------------------------------------------${NC}"
}

run_bot() {
    if [ ! -f "install.sh" ]; then
        echo "install.sh پیدا نشد. مطمئن شید این اسکریپت داخل پوشه‌ی ریپازیتوریه."
        return
    fi
    bash install.sh
    echo ""
    read -r -p "برای بازگشت به منو Enter بزنید..." _
}

remove_bot() {
    echo -e "${RED}⚠ این کار سرویس ربات، فایل‌های نصب‌شده و venv رو کامل حذف می‌کنه.${NC}"
    read -r -p "مطمئنید؟ (yes برای تایید): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "لغو شد."
        read -r -p "برای بازگشت به منو Enter بزنید..." _
        return
    fi

    if systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE_NAME}.service"; then
        sudo systemctl stop "$SERVICE_NAME" 2>/dev/null
        sudo systemctl disable "$SERVICE_NAME" 2>/dev/null
        sudo rm -f "/etc/systemd/system/${SERVICE_NAME}.service"
        sudo systemctl daemon-reload
        echo "سرویس systemd حذف شد."
    fi

    rm -rf "$REPO_DIR/venv" "$REPO_DIR/.build_artifacts" "$REPO_DIR"/*.so "$REPO_DIR"/*.c
    echo "فایل‌های نصب‌شده حذف شدن."
    echo ""
    read -r -p "اگه می‌خواید کل پوشه‌ی ریپازیتوری (${REPO_DIR}) هم پاک بشه، yes بزنید: " CONFIRM2
    if [ "$CONFIRM2" == "yes" ]; then
        cd /tmp
        rm -rf "$REPO_DIR"
        echo "پوشه حذف شد. خارج می‌شویم..."
        exit 0
    fi
    read -r -p "برای بازگشت به منو Enter بزنید..." _
}

while true; do
    banner
    read -r -p "انتخاب شما [0-2]: " CHOICE
    case "$CHOICE" in
        1) run_bot ;;
        2) remove_bot ;;
        0) echo "خدانگهدار."; exit 0 ;;
        *) echo "گزینه نامعتبر."; sleep 1 ;;
    esac
done
