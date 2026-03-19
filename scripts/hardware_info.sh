#!/bin/bash

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"


#SETUP
AUDIT_DIR="/tmp/sys_audit"
mkdir -p "$AUDIT_DIR"

output_file="$AUDIT_DIR/hardware_short_report.txt"
full_report_file="$AUDIT_DIR/hardware_full_report.txt"
pdf_report_file="$AUDIT_DIR/hardware_report.pdf"

> "$full_report_file" # clear the old content



#Date and time
curent_time=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "${BOLD}${CYAN}Hardware Info Scan - $curent_time${RESET}"
echo -e "Hardware info Scan - $curent_time" >> "$output_file"

#BANNER
echo -e "${BOLD}${CYAN}"
echo " _   _               _                          ___        __       "  
echo "| | | | __ _ _ __ __| |_      ____ _ _ __ ___  |_ _|_ __  / _| ___  "
echo "| |_| |/ _\` | '__/ _\` \\ \\ /\\ / / _\` | '__/ _ \\  | || '_ \\| |_ / _ \\"
echo "|  _  | (_| | | | (_| |\\ V  V / (_| | | |  __/  | || | | |  _| (_) |"
echo "|_| |_|\__,_|_|  \__,_| \\_/\\_/ \__,_|_|  \___| |___|_| |_|_|  \___/ "
echo -e "${RESET}"
echo -e "${CYAN}Collecting Hardware information...${RESET}"
#Scocial links

echo ""

echo -e "${GREEN}========================================${RESET}"
echo -e "${BOLD}${YELLOW}🔗 CONNECT WITH US${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo -e "${WHITE}   GitHub:${RESET} https://github.com/bibo2104818-ops"
echo -e "${WHITE}   GitHub:${RESET} https://github.com/imadtaibi573-design"
echo -e "${GREEN}========================================${RESET}"
echo -e "${BOLD}${YELLOW}📌 Project Links:${RESET}"
echo -e "${WHITE}   • GitHub Repository:${RESET} https://github.com/bibo2104818-ops/OS2_project"
# typing effect funtion
type_effect() {
    text="$1"
    for ((i=0; i < ${#text}; i++)); do
       echo -ne "${text:$i:1}"
       sleep 0.02
    done
    echo ""
}
print_save() {
     text="$1"
    echo -e "$text" 

    # Removing ANSI colors for saving
    clean_text=$(echo -e "$text" | sed 's/\x1B\[[0-9;]*[mK]//g')
   
    if [[ "$clean_text" != *"━━━━"* ]]; then
        
        echo "$clean_text" >> "$full_report_file"

       
        if [[ "$output_choice" == "y" || "$output_choice" == "Y" ]]; then
            echo "$clean_text" >> "$output_file"
        fi
    fi
}
print_header() {
    header="$1"
    echo ""
    print_save "${BOLD}${CYAN}════════════════════════════════════════${RESET}"
    print_save "${BOLD}${CYAN}  $header${RESET}"
    print_save "${BOLD}${CYAN}════════════════════════════════════════${RESET}"
    echo ""
}
spinner() {
    pid=$!
    spin='-\|/'
    i=0
    while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) % 4))
    printf "\r${YELLOW}[%c] Loading...${RESET}" "${spin:$i:1}"
    sleep .1
    done
    printf "\r${GREEN}[✔] Done!            ${RESET}\n"
}
echo ""
read -p "Do you want to save the output to a file? (y/n): " output_choice
echo ""
#Fake loading
echo -ne "${CYAN}Collecting Hardware Info..."
type_effect
echo -ne "${RESET}"
#type_effect "${CYAN}Collecting Hardware Info...${RESET}"
sleep 2 & 
spinner
echo ""
echo -ne "${CYAN}Processing Data..."
type_effect
echo -ne "${RESET}"
sleep 1


print_save "${GREEN}========================================${RESET}"
#CPU information
cpu_info=$(lscpu)
model=$(echo "$cpu_info" | awk -F ':' '/Model name/ {print $2}' | xargs)
vendor=$(echo "$cpu_info" | awk -F ':' '/Vendor ID/ {print $2}' | xargs)
arch=$(echo "$cpu_info" | awk -F ':' '/Architecture/ {print $2}' | xargs)
family=$(echo "$cpu_info" | awk -F ':' '/CPU family/ {print $2}' | xargs)
cores=$(echo "$cpu_info" | awk -F ':' '/Core\(s\) per socket/ {print $2}' | xargs)
threads=$(echo "$cpu_info" | awk -F ':' '/Thread\(s\) per core/ {print $2}' | xargs)
max_mhz=$(echo "$cpu_info" | awk -F ':' '/CPU max MHz/ {print $2}' | xargs)
virtualization=$(echo "$cpu_info" | grep 'Virtualization' | awk -F: '{print $2}'| xargs)
L1_cache=$(echo "$cpu_info" | grep 'L1d cache' | awk -F: '{print $2}'| xargs)
L2_cache=$(echo "$cpu_info" | grep 'L2 cache' | awk -F: '{print $2}'| xargs)
L3_cache=$(echo "$cpu_info" | grep 'L3 cache' | awk -F: '{print $2}'| xargs)

#gpu:
gpu=$(lspci | grep -i 'vga\|3d')
if [ -z "$gpu" ]; then
    gpu="No GPU detected"
fi
MEM_TOTAL=$(free -h | awk '/^Mem:/ {print $2}') 
MEM_USED=$(free -h  | awk '/^Mem:/ {print $3}')
MEM_FREE=$(free -h  | awk '/^Mem:/ {print $4}')

SWAP_TOTAL=$(free -h | awk '/^Swap:/ {print $2}')
SWAP_USED=$(free -h | awk '/^Swap:/ {print $3}')
SWAP_FREE=$(free -h | awk '/^Swap:/ {print $4}')
#disk info:
#disk_info=$(df -h / /home 2>/dev/null)
if command -v lsblk >/dev/null 2>&1; then
    disk_info=$(lsblk -o NAME,MODEL,SIZE,TYPE,MOUNTPOINT  -l -n 2>/dev/null | grep -v "^loop") 
    else
        disk_info=$(df -h)

fi
disk_usage=$(df -h --total | grep total)
#uptime:
uptime=$(uptime -p)
#Network interfaces & IP addresses
network_interfaces() {
    if command -v ip >/dev/null 2>&1; then
        Interface_summary=$(ip -brief addr)
        print_save "${BOLD}${CYAN}Interface Summary:${RESET}"
        print_save "$Interface_summary"
        echo ""

        for iface in $(ls /sys/class/net); do
            print_save "${BOLD}Interface:${RESET} $iface"
            state=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
            mac=$(cat /sys/class/net/$iface/address 2>/dev/null)
            mtu=$(cat /sys/class/net/$iface/mtu 2>/dev/null)
            
            print_save "State: $state"
            print_save "MAC Address: $mac"
            print_save "MTU: $mtu"

            if command -v ethtool >/dev/null 2>&1; then
                speed=$(ethtool $iface 2>/dev/null | grep 'Speed:' | awk '{print $2}')
                duplex=$(ethtool $iface 2>/dev/null | grep 'Duplex:' | awk '{print $2}')
                [ -n "$speed" ] && print_save "Speed: $speed"
                [ -n "$duplex" ] && print_save "Duplex: $duplex"
            fi

            echo ""
        done

        default_gateway=$(ip route | grep default)
        print_save "${BOLD}Default Gateway:${RESET} $default_gateway"

        DNS_servers=$(grep "nameserver" /etc/resolv.conf)
        print_save "${BOLD}DNS Servers:${RESET} $DNS_servers"

        active_net_connections=$(ss -tun | wc -l | awk '{print "Total Connections: "$1}')
        print_save "${BOLD}Active Connections:${RESET} $active_net_connections"

    else
        print_save "Network tools not available..."
    fi
    echo ""
}
#PCI devices
PCI_devices(){
    if command -v lspci >/dev/null 2>&1; then
        lspci -tv | while read -r line; do
                clean_line=$(echo "$line" | sed -E 's/\[[0-9a-f:.]+\]//g')
                clean_line=$(echo "$clean_line" | sed 's/^\s*//')
                print_save "$clean_line"
                    
        done
    else
        print_save "lspci not available..."
    fi
    echo ""
# this one is detailed i will add a summariwed one for users who don't want details
}
bios_info(){
    if command -v dmidecode >/dev/null 2>&1; then
        if [ "$EUID" -ne 0 ]; then
            echo "Please run as root: sudo ./hardware_info.sh"
        else
            sudo dmidecode --type bios   | grep -E "Vendor|Version|Release Date|ROM Size|Characteristics|BIOS Revision|Firmware Revision|Language Description Format|Installable Languages|Currently Installed Language" | while read -r line; do
                print_save "$line"
            done
        fi
    else
        print_save "dmicode not available."
    fi
    echo ""



}



print_save "${BOLD}${CYAN}Uptime:${RESET} $uptime"
print_save "${GREEN}========================================${RESET}"
print_save "${BOLD}${CYAN}---- GPU Information ----${RESET}"
print_save "${WHITE}GPU:${RESET} $gpu"
print_save "${GREEN}========================================${RESET}"
print_save "${BOLD}${CYAN}---- Disk Information ----${RESET}"
print_save "$disk_info"
print_save "$disk_usage"
print_save "${GREEN}========================================${RESET}"
print_save "${BOLD}${CYAN}---- RAM Information ----${RESET}"
print_save "${WHITE}Total Memory:${RESET}$MEM_TOTAL"
print_save "${WHITE}Memory Used:${RESET}$MEM_USED"
print_save "${WHITE}Free Memory:${RESET}$MEM_FREE"
print_save "${WHITE}Swap Total${RESET}$SWAP_TOTAL"
print_save "${WHITE}Swap Used:${RESET}$SWAP_USED"
print_save "${WHITE}Swap Free:${RESET}$SWAP_FREE"
print_save "${GREEN}========================================${RESET}"
print_save "${BOLD}${CYAN}---- CPU Information ----${RESET}"
print_save "${WHITE}Model:${RESET} $model" 
print_save "${WHITE}Vendor:${RESET} $vendor" 
print_save "${WHITE}Architecture:${RESET} $arch"
print_save "${WHITE}CPU Family:${RESET} $family" 
print_save "${WHITE}Cores per Socket:${RESET} $cores" 
print_save "${WHITE}Threads per Core:${RESET} $threads" 
print_save "${WHITE}Total Threads:${RESET} $(nproc)" 
print_save "${WHITE}Max MHz:${RESET} $max_mhz" 
print_save "${GREEN}========================================${RESET}"
print_save "${BOLD}${CYAN}---- Network Interface: ----${RESET}"
network_interfaces
print_save "${GREEN}========================================${RESET}"
print_save "${BOLD}${CYAN}---- PCI devices: ----${RESET}"
PCI_devices
print_save "${GREEN}========================================${RESET}"
print_save "${BOLD}${CYAN}---- BIOS information: ----${RESET}"
bios_info
print_save "${GREEN}========================================${RESET}"

echo -e "${BOLD}${CYAN}Scan Completed Successfully.${RESET}"

echo -e "${GREEN}========================================${RESET}"
echo -e "${BOLD}${WHITE}     Thank you for using this tool!     ${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""

# PDF conversion 
echo ""
read -p "Do you want to generate a PDF report? (y/n): " pdf_choice

if [[ "$pdf_choice" == "y" || "$pdf_choice" == "Y" ]]; then
    echo -e "${CYAN}Generating PDF report...${RESET}"
    
    # Remove Unicode lines and convert
    grep -v "━" "$full_report_file" | a2ps -o - | ps2pdf - "$pdf_report_file"
    
    if [ -f "$pdf_report_file" ]; then
        echo -e "${GREEN}✓ PDF saved to: $pdf_report_file${RESET}"
    fi
fi