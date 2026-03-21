#!/bin/bash

# COLORS
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

# SETUP
AUDIT_DIR="/tmp/sys_audit"
mkdir -p "$AUDIT_DIR"

output_file="$AUDIT_DIR/software_short_report.txt"
full_report_file="$AUDIT_DIR/software_full_report.txt"
pdf_report_file="$AUDIT_DIR/software_report.pdf"

> "$full_report_file" # clear the old content


# DATE AND TIME
current_time=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "${BOLD}${CYAN}Software Info Scan - $current_time${RESET}"
echo "Software Info Scan - $current_time" >> "$output_file"
echo "Software Info Scan - $current_time" >> "$full_report_file"

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

read -p "Do you want to save the output to a file? (y/n): " output_choice

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

    echo "$clean_text" >> "$full_report_file"

    if [[ "$output_choice" == "y" || "$output_choice" == "Y" ]]; then
        echo "$clean_text" >> "$output_file"
    fi
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

# Open ports
open_ports() {
    print_save "${BOLD}${CYAN}---- Open Listening Ports ----${RESET}"

    ss -tuln | awk 'NR>1 {
        split($5,a,":")
        print a[length(a)]
    }' | sort -u | while read -r port; do
        print_save "Port: $port"
    done

    echo ""
}

print_save "${GREEN}========================================${RESET}"

print_save "${BOLD}${CYAN}---- Operating System Information ----${RESET}"
if [ -f /etc/os-release ]; then
    source /etc/os-release
    print_save "${WHITE}OS Name:${RESET} $NAME"
    print_save "${WHITE}OS Version:${RESET} $VERSION"
    print_save "${WHITE}Distribution ID:${RESET} $ID"
fi

print_save "${WHITE}Kernel Version:${RESET} $(uname -r)"
print_save "${WHITE}Kernel Architecture:${RESET} $(uname -m)"
print_save "${WHITE}Hostname:${RESET} $(hostname)"
print_save "${GREEN}========================================${RESET}"

# System Uptime
print_save "${BOLD}${CYAN}---- System Uptime ----${RESET}"
print_save "${WHITE}Uptime:${RESET} $(uptime -p)"
print_save "${GREEN}========================================${RESET}"

# Package Manager
print_save "${BOLD}${CYAN}---- Package Manager ----${RESET}"
if command -v dpkg >/dev/null 2>&1; then
    print_save "${WHITE}Package Manager:${RESET} dpkg (Debian/Ubuntu)"
    print_save "${WHITE}Total Installed Packages:${RESET} $(dpkg -l | wc -l)"
elif command -v rpm >/dev/null 2>&1; then
    print_save "${WHITE}Package Manager:${RESET} rpm (RedHat/CentOS)"
    print_save "${WHITE}Total Installed Packages:${RESET} $(rpm -qa | wc -l)"
else
    print_save "${WHITE}Package Manager:${RESET} Unknown"
fi
print_save "${GREEN}========================================${RESET}"

# Running Services
print_save "${BOLD}${CYAN}---- Running Services ----${RESET}"
if command -v systemctl >/dev/null 2>&1; then
    print_save "${WHITE}Active Services:${RESET} $(systemctl list-units --type=service --state=running | wc -l)"
else
    print_save "${WHITE}Service Manager:${RESET} Not detected"
fi
print_save "${GREEN}========================================${RESET}"

# Logged In Users
print_save "${BOLD}${CYAN}---- Logged In Users ----${RESET}"
print_save "${WHITE}Users:${RESET} $(users)"
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
echo ""
read -p "Do you want to generate a PDF report? (y/n): " pdf_choice

if [[ "$pdf_choice" == "y" || "$pdf_choice" == "Y" ]]; then
    echo -e "${CYAN}Generating PDF report...${RESET}"

    if [ -s "$full_report_file" ]; then
        grep -v "━" "$full_report_file" | a2ps -o - | ps2pdf - "$pdf_report_file"

        if [ -f "$pdf_report_file" ]; then
            echo -e "${GREEN}✓ PDF saved to: $pdf_report_file${RESET}"
        else
            echo -e "${RED}PDF generation failed.${RESET}"
        fi
    else
        echo -e "${RED}Report file is empty or missing: $full_report_file${RESET}"
    fi
fi