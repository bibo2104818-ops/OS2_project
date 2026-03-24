#!/bin/bash

# COLORS
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"


if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}${BOLD}Please run this script as root (use sudo).${RESET}"
    exit 1
fi

# SETUP
AUDIT_DIR="/var/log/sys_audit"
if [ ! -d "$AUDIT_DIR" ]; then
    sudo mkdir -p "$AUDIT_DIR"
    sudo chmod 755 "$AUDIT_DIR"
fi
SHORT_REPORT="$AUDIT_DIR/software_short_report.txt"
FULL_REPORT="$AUDIT_DIR/software_full_report.txt"
PDF_REPORT="$AUDIT_DIR/software_report.pdf"

> "$SHORT_REPORT" # clear the old content
> "$FULL_REPORT"


# DATE AND TIME
current_time=$(date +"%Y-%m-%d %H:%M:%S")
file_ts=$(date +"%d-%m-%y_%H-%M")
HOSTNAME=$(hostname)
echo -e "${BOLD}${CYAN}Software Info Scan - $current_time${RESET}"
echo "Software Info Scan - $current_time" >> "$SHORT_REPORT"
echo "Software Info Scan - $current_time" >> "$FULL_REPORT"

# BANNER
echo -e "${BOLD}${CYAN}"
echo " ____         __ _                          "
echo "/ ___|  ___  / _| |___      ____ _ _ __ ___ "
echo "\\___ \\ / _ \\| |_| __\\ \\ /\\ / / _\` | '__/ _ \\"
echo " ___) | (_) |  _| |_ \\ V  V / (_| | | |  __/"
echo "|____/ \\___/|_|  \\__| \\_/\\_/ \\__,_|_|  \\___|"
echo "                                            "
echo " ___        __                            _   _             "
echo "|_ _|_ __  / _| ___  _ __ _ __ ___   __ _| |_(_) ___  _ __  "
echo " | || '_ \\| |_ / _ \\| '__| '_ \` _ \\ / _\` | __| |/ _ \\| '_ \\ "
echo " | || | | |  _| (_) | |  | | | | | | (_| | |_| | (_) | | | |"
echo "|___|_| |_|_|  \\___/|_|  |_| |_| |_|\\__,_|\\__|_|\\___/|_| |_|"
echo -e "${RESET}"
echo -e "${CYAN}Collecting Software Information...${RESET}"


type_effect() {
    text="$1"
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${text:$i:1}"
        sleep 0.02
    done
    echo ""
}

print_save() {
    text="$1"
    echo -e "$text"
    clean_text=$(echo -e "$text" | sed 's/\x1B\[[0-9;]*[mK]//g')
    echo "$clean_text" >> "$FULL_REPORT"

}

spinner() {
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
        i=$(((i+1) % 4))
        printf "\r${YELLOW}[%c] Loading...${RESET}" "${spin:$i:1}"
        sleep .1
    done
    printf "\r${GREEN}[✔] Done!            ${RESET}\n"
}

# Fake loading
echo -ne "${CYAN}Collecting Software Info..."
type_effect
echo -ne "${RESET}"
sleep 2 &
spinner

echo ""
echo -ne "${CYAN}Processing Data..."
type_effect
echo -ne "${RESET}"
sleep 1
#Active processes
active_processes() {
    print_save "${BOLD}${CYAN}---- Top 10 Active Processes (by CPU) ----${RESET}"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 11 | while read -r line; do
        print_save "$line"
    done

}

# Open ports
open_ports() {
    print_save "${BOLD}${CYAN}---- Open Listening Ports ----${RESET}"
    port_list=""
    ss -tuln | awk 'NR>1 {
        split($5,a,":")
        print a[length(a)]
    }' | sort -u | while read -r port; do
        print_save "Port: $port"
        port_list="$port_list $port"

    done
    echo "Open ports:$port_list" >> "$SHORT_REPORT"

    echo ""
}

print_save "${GREEN}========================================${RESET}"

print_save "${BOLD}${CYAN}---- Operating System Information ----${RESET}"
if [ -f /etc/os-release ]; then
    source /etc/os-release
    print_save "${WHITE}OS Name:${RESET} $NAME"
    print_save "${WHITE}OS Version:${RESET} $VERSION"
    print_save "${WHITE}Distribution ID:${RESET} $ID"
    echo "OS: $NAME $VERSION" >> "$SHORT_REPORT"

fi

print_save "${WHITE}Kernel Version:${RESET} $(uname -r)"
print_save "${WHITE}Kernel Architecture:${RESET} $(uname -m)"
print_save "${WHITE}Hostname:${RESET} $(hostname)"
echo "Kernel: $(uname -r)" >> "$SHORT_REPORT"
print_save "${GREEN}========================================${RESET}"

# System Uptime
print_save "${BOLD}${CYAN}---- System Uptime ----${RESET}"
print_save "${WHITE}Uptime:${RESET} $(uptime -p)"
echo "Uptime: $(uptime -p)" >> "$SHORT_REPORT"
print_save "${GREEN}========================================${RESET}"

# Package Manager
print_save "${BOLD}${CYAN}---- Package Manager ----${RESET}"
if command -v dpkg >/dev/null 2>&1; then
    total_pkgs=$(dpkg -l | wc -l)
    print_save "${WHITE}Package Manager:${RESET} dpkg (Debian/Ubuntu)"
    print_save "${WHITE}Total Installed Packages:${RESET} $total_pkgs"
    echo "Installed packages: $total_pkgs" >> "$SHORT_REPORT"
    echo "" >> "$FULL_REPORT"
    
elif command -v rpm >/dev/null 2>&1; then
    total_pkgs=$(rpm -qa | wc -l)
    print_save "${WHITE}Package Manager:${RESET} rpm (RedHat/CentOS)"
    print_save "${WHITE}Total Installed Packages:${RESET} $total_pkgs"
    echo "Installed Packages: $total_pkgs" >> "$SHORT_REPORT"
    echo "" >> "$FULL_REPORT"
    echo "---- Detailed Installed Packages ----" >> "$FULL_REPORT"
  

else
    print_save "${WHITE}Package Manager:${RESET} Unknown"
fi
print_save "${GREEN}========================================${RESET}"

# Running Services
print_save "${BOLD}${CYAN}---- Running Services ----${RESET}"
if command -v systemctl >/dev/null 2>&1; then
    active_services=$(systemctl list-units --type=service --state=active | wc -l)
    print_save "${WHITE}Active Services:${RESET} $active_services"
    echo "Active services: $active_services" >> "$SHORT_REPORT"
else
    print_save "${WHITE}Service Manager:${RESET} Not detected"
    echo "Service Manager: Not detected"
fi
print_save "${GREEN}========================================${RESET}"
active_processes
print_save "${GREEN}========================================${RESET}"

# Logged In Users
print_save "${BOLD}${CYAN}---- Logged In Users ----${RESET}"
print_save "${WHITE}Users:${RESET} $(users)"
echo "Logged in Users: $(users)" >> "$SHORT_REPORT"
print_save "${GREEN}========================================${RESET}"

# Environment Info
print_save "${BOLD}${CYAN}---- Environment Information ----${RESET}"
print_save "${WHITE}Current User:${RESET} $(whoami)"
print_save "${WHITE}Shell:${RESET} $SHELL"
print_save "${WHITE}Home Directory:${RESET} $HOME"
print_save "${GREEN}========================================${RESET}"

# Open ports section
open_ports
print_save "${GREEN}========================================${RESET}"

echo -e "${BOLD}${GREEN}Software Scan Completed Successfully.${RESET}"

# PDF conversion
OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '\"')

echo -ne "\x1b[36mGenerating PDF report... \x1b[0m"
{
    echo "---"
    echo "title: \"System Software Audit Report\""
    echo "subtitle: \"Host: $HOSTNAME | OS: $OS_NAME | Date: $current_time\""
    echo "author: \"Automated Security Audit Tool v1.0\""
    echo "geometry: margin=0.8in"
    echo "mainfont: \"DejaVu Sans\""
    echo "monofont: \"DejaVu Sans Mono\""
    echo "---"
    echo ""
    echo "# 1. Legal Disclaimer"
    echo "This document is for authorized use only. Handle according to security policies."
    echo ""
    echo "# 2. Executive Summary"
    echo "Automated software and OS inventory performed on **$HOSTNAME**."
    echo ""
    echo "# 3. Technical Data"
    echo '\begin{verbatim}'
    
    sed 's/\x1b\[[0-9;]*[mK]//g' "$FULL_REPORT" | \
    sed 's/├/+/g; s/└/+/g; s/│/|/g; s/─/-/g; s/═/-/g; s/━/-/g' | \
    sed 's/========================================/----------------------------------------/g'
    
    echo '\end{verbatim}'
} | pandoc -o "$PDF_REPORT" --pdf-engine=xelatex

#  ensure Pandoc succeeded
if [ -f "$PDF_REPORT" ]; then
    echo -e "\x1b[32m[✔] Done!\x1b[0m"
else
    echo -e "\x1b[31m[!] Failed.\x1b[0m"
fi

echo -e "\n\x1b[1m\x1b[32m--- Audit Complete ---\x1b[0m"
echo -e "\x1b[36mReports are available at:\x1b[0m"
echo -e "  \x1b[97mShort report:\x1b[0m $(basename "$SHORT_REPORT")"
echo -e "  \x1b[97mFull report:\x1b[0m  $(basename "$FULL_REPORT")"
echo -e "  \x1b[97mPDF report:\x1b[0m   $(basename "$PDF_REPORT")"
echo ""