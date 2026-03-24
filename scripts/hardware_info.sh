#!/bin/bash

#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

#important:
if [[ $EUID -ne 0 ]]; then
    echo "${RED}${BOLD}Please run this script as root (use sudo).${RESET}"
    exit 1
fi
#SETUP
AUDIT_DIR="/var/log/sys_audit"
if [ ! -d "$AUDIT_DIR" ]; then
    sudo mkdir -p "$AUDIT_DIR"
    sudo chmod 755 "$AUDIT_DIR"
fi

#Date and time
current_time=$(date +"%d-%m-%y %H:%M:%S")
file_ts=$(date +"%d-%m-%y_%H-%M")

SHORT_REPORT="$AUDIT_DIR/short_report_$file_ts.txt"
FULL_REPORT="$AUDIT_DIR/full_report_$file_ts.txt"
PDF_REPORT="$AUDIT_DIR/hardware_report_$file_ts.pdf"

touch "$SHORT_REPORT"
touch "$FULL_REPORT"
#headers
echo "NATIONAL SCHOOL OF CYBERSECURITY - SHORT REPORT" > "$SHORT_REPORT"
echo "Scan Date: $current_time" >> "$SHORT_REPORT"
echo "----------------------------------------" >> "$SHORT_REPORT"
echo "NATIONAL SCHOOL OF CYBERSECURITY - FULL TECHNICAL REPORT" > "$FULL_REPORT"
echo "Hardware info Scan - $current_time" >> "$FULL_REPORT"
echo "----------------------------------------" >> "$FULL_REPORT"




#BANNER
echo -e "${BOLD}${CYAN}"
echo " _   _               _                          ___        __       "  
echo "| | | | __ _ _ __ __| |_      ____ _ _ __ ___  |_ _|_ __  / _| ___  "
echo "| |_| |/ _\` | '__/ _\` \\ \\ /\\ / / _\` | '__/ _ \\  | || '_ \\| |_ / _ \\"
echo "|  _  | (_| | | | (_| |\\ V  V / (_| | | |  __/  | || | | |  _| (_) |"
echo "|_| |_|\__,_|_|  \__,_| \\_/\\_/ \__,_|_|  \___| |___|_| |_|_|  \___/ "
echo -e "${RESET}"
echo -e "${CYAN}Collecting Hardware information...${RESET}"


echo ""

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
   local text="$1"
   echo -e "$text"
   echo -e "$text" | sed 's/\x1B\[[0-9;]*[mK]//g' >> "$FULL_REPORT"
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


sensor_data=$(sensors)


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
cpu_temp=$(echo "$sensor_data" | awk '/Package id 0/ {print $4}')
core_tep=$(echo "$sensor_data" | grep 'Core')


get_cpu_usage() {
    read cpu user nice system idle iowait irq softirq steal guest < /proc/stat

    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle1=$((idle + iowait))

    sleep 1

    read cpu user nice system idle iowait irq softirq steal guest < /proc/stat

    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))
    idle2=$((idle + iowait))

    total_diff=$((total2 - total1))
    idle_diff=$((idle2 - idle1))

    cpu_usage=$(( (100 * (total_diff - idle_diff)) / total_diff ))

    echo "$cpu_usage"
}




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
nvme_temp=$("$sensors" | awk '/Composite/ {print $2}')


#uptime:
uptime=$(uptime -p)
#Network interfaces & IP addresses
network_interfaces() {
    {
        echo "---- Network Summary ----"
        # extracting only the primary IP and interface name
        echo "Primary IP: $(hostname -I | awk '{print $1}')"
        echo "Gateway: $(ip route | grep default | awk '{print $3}')"
        echo "Active connections: $(ss -tuln | wc -l)"

    } >> "$SHORT_REPORT"
    #full report

    print_save "${BOLD}${CYAN}---- Network Interface: ----${RESET}"
    if command -v ip >/dev/null 2>&1; then
        Interface_summary=$(ip -brief addr)
        print_save "${BOLD}${CYAN}Interface Summary:${RESET}"
        print_save "$Interface_summary"
        echo ""

        for iface in $(ls /sys/class/net); do
            print_save "\x1b[1m\x1b[36mInterface:\x1b[0m $iface"
            state=$(cat /sys/class/net/$iface/operstate 2>/dev/null)
            mac=$(cat /sys/class/net/$iface/address 2>/dev/null)
            mtu=$(cat /sys/class/net/$iface/mtu 2>/dev/null)
            
            print_save "\x1b[36mState:\x1b[0m $state"
            print_save "\x1b[36mMAC Address:\x1b[0m $mac"
            print_save "\x1b[36mMTU:\x1b[0m $mtu"

            if command -v ethtool >/dev/null 2>&1; then
                speed=$(ethtool $iface 2>/dev/null | grep 'Speed:' | awk '{print $2}')
                duplex=$(ethtool $iface 2>/dev/null | grep 'Duplex:' | awk '{print $2}')
                [ -n "$speed" ] && print_save "\x1b[36m\x1b\e[1mSpeed:\x1b[0m $speed"
                [ -n "$duplex" ] && print_save "\x1b[36m\x1b\e[1mDuplex:\x1b[0m $duplex"
            fi

            echo ""
        done

        default_gateway=$(ip route | grep default)
        print_save "\x1b[36mDefault Gateway:\x1b[0m $default_gateway"

        DNS_servers=$(grep "nameserver" /etc/resolv.conf)
        print_save "\x1b[36mDNS Servers:\x1b[0m $DNS_servers"

        active_net_connections=$(ss -tun | wc -l | awk '{print "Total Connections: "$1}')
        print_save "\x1b[36mActive Connections:\x1b[0m $active_net_connections"

    else
        print_save "Network tools not available..."
    fi
    echo ""
}
#PCI devices
PCI_devices(){
    print_save "${BOLD}${CYAN}---- PCI Devices ----${RESET}"
    if command -v lspci >/dev/null 2>&1; then
        lspci | grep -Ei "Ethernet|Network|SATA|VGA|Audio" | cut -d' ' -f2- | while read -r line; do
            echo " - $line" >> "$SHORT_REPORT"
        done
    else
        echo "- lspci not available" >> "$SHORT_REPORT"
    fi
    #for the full report
    if command -v >/dev/null 2>&1; then
        lspci -tv | while read -r line; do
            clean_line=$(echo "$line" | sed 's/^\*//')
            [ -n "$clean_line" ] && print_save "$clean_line"
        done
    else
        print_save "lspci not available..."
    fi
        echo "" >> "$FULL_REPORT"

}

bios_info(){
    local BIOS_VENDOR=$(dmidecode -s bios-vendor 2>/dev/null | xargs)
    local BIOS_VERSION=$(dmidecode -s bios-version 2>/dev/null | xargs)
    {
    echo "BIOS Vendor: ${BIOS_VENDOR:-N/A}"
    echo "BIOS Version: ${BIOS_VERSION:-N/A}"
    } >> "$SHORT_REPORT"
    print_save "${BOLD}${CYAN}---- BIOS Technical Details ----${RESET}"
    if command -v dmidecode >/dev/null 2>&1; then
        if [ "$EUID" -ne 0 ]; then
            echo "Please run as root: sudo ./hardware_info.sh"
        else
            sudo dmidecode --type bios 2>/dev/null  | grep -Ei "Vendor|Version|Release Date|ROM Size|Characteristics|BIOS Revision|Firmware Revision|Language Description Format|Installable Languages|Currently Installed Language" | while read -r line; do
                clean_line=$(echo "$line" | xargs)
                colored_line=$(echo "$clean_line" | sed "s/^\([^:]*:\)/\x1b[36m\1\x1b[0m/")
                [ -n "$clean_line" ] && print_save "  $colored_line"
            done
        fi
    else
        print_save "dmicode not available."
    fi

    echo "" >> "$FULL_REPORT"
}

motherboard_info(){
         print_save "${BOLD}${CYAN}---- Motherboard information ----${RESET}"
        if command -v dmidecode >/dev/null 2>&1; then
            local vendor=$(dmidecode -s system-manufacturer 2>/dev/null | xargs)
            local product=$(dmidecode -s system-product-name 2>/dev/null | xargs)
            local version=$(dmidecode -s baseboard-version 2>/dev/null | xargs)
            echo "Vendor: ${vendor:-N/A}" >> "$SHORT_REPORT"
            echo "Product: ${product:-N/A}" >> "$SHORT_REPORT"
            echo "Version: ${version:-N/A}" >> "$SHORT_REPORT"
        
        
            print_save "\x1b[1m\x1b[36m---- Detailed System Hardware ----\x1b[0m"
            local keys=("baseboard-manufacturer" "baseboard-product-name" "baseboard-version" "baseboard-serial-number" "baseboard-asset-tag" "chassis-manufacturer" "chassis-type" "chassis-version" "chassis-serial-number" "chassis-asset-tag")
            for key in "${keys[@]}"; do
            local value=$(sudo dmidecode -s "$key" 2>/dev/null | xargs)
            
            if [[ "$key" == "chassis-manufacturer" ]]; then
                print_save ""
                print_save "\x1b[1m\x1b[36m---- chassis technical details ----\x1b[0m"
            fi
            
            if [ -n "$value" ] && [[ "$value" != "not specified" ]]; then
                local label=$(echo "$key" | sed 's/-/ /g')
                print_save "  \x1b[36m${label}:\x1b[0m ${value}"
                
                if [[ "$key" == "baseboard-manufacturer" || "$key" == "baseboard-product-name" ]]; then
                    echo "${label}: ${value}" >> "$SHORT_REPORT"
                fi
            fi
        done
    fi
}

        

cpu_info(){

    echo "CPU Model: ${model:-N/A}" >> "$SHORT_REPORT"
    print_save "\x1b[1m\x1b[36m---- CPU Information ----\x1b[0m"
    print_save "  \x1b[36mModel:\x1b[0m $model" 
    print_save "  \x1b[36mVendor:\x1b[0m $vendor" 
    print_save "  \x1b[36mArchitecture:\x1b[0m $arch"
    print_save "  \x1b[36mCPU Family:\x1b[0m $family" 
    print_save "  \x1b[36mCores:\x1b[0m $cores" 
    print_save "  \x1b[36mTotal Threads:\x1b[0m $(nproc)" 
    print_save "  \x1b[36mMax MHz:\x1b[0m $max_mhz"

   cpu_usage=$(get_cpu_usage)
   print_save "  \x1b[36mCPU Usage:\x1b[0m ${cpu_usage}%"
 
    cpu_temp=$(echo "$sensor_data" | awk '/Package id 0/ {print $4}')
    if [ -n "$cpu_temp" ]; then
        print_save "  \x1b[36mCPU Temp:\x1b[0m $cpu_temp"
    fi

    core_temps=$(echo "$sensor_data" | awk '/Core [0-9]+/ {printf "%s:%s ", $2, $3}')
    if [ -n "$core_temps" ]; then
        print_save "  \x1b[36mCore Temps:\x1b[0m $core_temps"
    fi

 
}

ram_info(){
    #short report
    print_save "${WHITE}Total Memory: ${RESET}$MEM_TOTAL" >> "$SHORT_REPORT"
    print_save "${WHITE}Memory Used: ${RESET}$MEM_USED" >> "$SHORT_REPORT"
    print_save "${WHITE}Free Memory: ${RESET}$MEM_FREE" >> "$SHORT_REPORT"
    print_save "${WHITE}Swap Total: ${RESET}$SWAP_TOTAL" >> "$SHORT_REPORT"
    print_save "${WHITE}Swap Used: ${RESET}$SWAP_USED" >> "$SHORT_REPORT"
    print_save "${WHITE}Swap Free: ${RESET}$SWAP_FREE" >> "$SHORT_REPORT"
    #full report
    print_save "${BOLD}${CYAN}---- Physical Memory Modules (RAM) ----${RESET}"
    if [ "$EUID" -ne 0 ]; then
        print_save "  [Error] Root privileges required for RAM hardware audit."
    else
        # Type 17 is the specific DMI type for Memory Devices 
        dmidecode -t 17 2>/dev/null | grep -Ei "Size|Type|Speed|Manufacturer|Part Number|Locator" | grep -iv "No Module Installed" | while read -r line; do
            clean_line=$(echo "$line" | sed 's/^\*//') #removing spaces
            #adding a separator for every new RAM stick
            if [[ "$clean_line" == "Handle"* ]]; then
                ((i++))
                print_save "${YELLOW}---------------- [ RAM Stick #$i ] ----------------${RESET}"
                continue
            fi
            colored_line=$(echo "$clean_line" | sed "s/^\([^:]*:\)/\x1b[36m\1\x1b[0m/")
                [ -n "$clean_line" ] && print_save "    $colored_line"

            
        done
    fi
    echo "" >> "$FULL_REPORT"
}
gpu_info(){
    #short report
    echo "GPU: ${gpu:-No GPU Detected}" >> "$SHORT_REPORT"
    echo "Disk Usage: $disk_usage" >> "$SHORT_REPORT"

    #full report
    print_save "${BOLD}${CYAN}---- GPU Information ----${RESET}"
    print_save "\x1b[36mGPU:\x1b[0m $gpu"
}
disk_info(){
    #short report
    echo "Disk Usage: $disk_usage" >> "$SHORT_REPORT"
    #full report
    print_save "${BOLD}${CYAN}---- Disk Information ----${RESET}"
    #-p, --paths (Print full device paths)
    local MAIN_DISK=$(lsblk -dno NAME | grep -Ei "sd|nvme" | head -n1)
    print_save "\x1b[36mPrimary Drive:\x1b[0m /dev/$MAIN_DISK"

    local nvme_temp=$(echo "$sensor_data" | awk '/nvme/ {found=1} found && /Composite/ {print $2; exit}')
    if [ -n "$nvme_temp" ]; then
        print_save "\x1b[36mNVMe Temperature:\x1b[0m $nvme_temp"
    fi

    # clean aligned output
    print_save "  \x1b[36mDEVICE          TYPE     SIZE    FSTYPE   MOUNTPOINT\x1b[0m"
    lsblk -pno NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT | grep -v "loop" | while read -r line; do
        clean_line=$(echo "$line" | awk '{printf "%-15s %-8s %-7s %-8s %-s", $1, $2, $3, $4, $5}') 
        colored_line=$(echo "$clean_line" | sed "s|^\(/dev/[^ ]*\)|\x1b[36m\1\x1b[0m|")
        print_save "    $colored_line"
    done
    echo "" >> "$FULL_REPORT"
}
usb_devices(){
    print_save "${BOLD}${CYAN}---- USB Devices ----${RESET}"
    if command -v lsusb >/dev/null 2>&1; then
        local i=1
        lsusb | cut -d' ' -f7- | while read -r line; do
            echo "- Device $i: $line" >> "$SHORT_REPORT"
            ((i++))
        done
    else
        echo "lsusb not available" >> "$SHORT_REPORT"
    fi

    if command -v lsusb >/dev/null 2>&1; then
        local j=1
        lsusb | while read -r line; do
            print_save " \x1b[36mDevice $j:\x1b[0m $(echo "$line" | cut -d' ' -f7-)" 
            ((j++))
        done
    else
        print_save "[Error] lsusb command not founc"
    fi
    echo "" >> "$FULL_REPORT"

}
print_save "${BOLD}${CYAN}Uptime:${RESET} $uptime"
print_save "${GREEN}========================================${RESET}"
gpu_info
print_save "${GREEN}========================================${RESET}"
disk_info
print_save "${GREEN}========================================${RESET}"
ram_info
print_save "${GREEN}========================================${RESET}"
cpu_info
print_save "${GREEN}========================================${RESET}"
network_interfaces
print_save "${GREEN}========================================${RESET}"
PCI_devices
print_save "${GREEN}========================================${RESET}"
usb_devices
print_save "${GREEN}========================================${RESET}"
bios_info
print_save "${GREEN}========================================${RESET}"
motherboard_info
print_save "${GREEN}========================================${RESET}"


echo -e "${BOLD}${CYAN}Scan Completed Successfully.${RESET}"

echo -e "${GREEN}========================================${RESET}"
echo -e "${BOLD}${WHITE}     Thank you for using this tool!     ${RESET}"
echo -e "${GREEN}========================================${RESET}"
echo ""

# PDF conversion 
OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '\"')

    if [[ "$pdf_choice" =~ ^[yY]$ ]]; then
        echo -ne "\x1b[36mgenerating pdf... \x1b[0m"
        {
            echo "---"
            echo "title: \"system hardware audit report\""
            echo "subtitle: \"host: $HOSTNAME | os: $OS_NAME | date: $current_time\""
            echo "author: \"automated security audit tool v1.0\""
            echo "geometry: margin=0.8in"
            echo "mainfont: \"DejaVu Sans\""
            echo "monofont: \"DejaVu Sans Mono\""
            echo "header-includes:"
            echo "  - |"
            echo "    \\usepackage{fvextra}"
            echo "    \\DefineVerbatimEnvironment{Highlighting}{Verbatim}{breaklines,commandchars=\\\\\\{\\}}"
            echo "---"
            echo ""
            echo "# 1. legal disclaimer"
            echo "this document is for authorized use only. handle according to security policies."
            echo ""
            echo "# 2. executive summary"
            echo "automated hardware inventory performed on **$HOSTNAME**."
            echo ""
            echo "# 3. technical data"
            echo '```text'
            
            sed 's/\x1b\[[0-9;]*[mk]//g' "$FULL_REPORT" | \
            sed 's/├/+/g; s/└/+/g; s/│/|/g; s/─/-/g; s/═/-/g; s/━/-/g' | \
            sed 's/========================================/----------------------------------------/g'
            
            echo '```'
        } | pandoc -o "$PDF_REPORT" --pdf-engine=xelatex --highlight-style=tango
    fi

    echo -e "\n\x1b[1m\x1b[32m--- audit complete ---\x1b[0m"
    echo -e "\x1b[36mreports are available at:\x1b[0m"
    echo -e "  \x1b[97mshort report:\x1b[0m $(basename "$SHORT_REPORT")"
    echo -e "  \x1b[97mfull report:\x1b[0m  $(basename "$FULL_REPORT")"

    if [[ -f "$PDF_REPORT" && "$pdf_choice" =~ ^[yY]$ ]]; then
        echo -e "  \x1b[97mpdf report:\x1b[0m   $(basename "$PDF_REPORT")"
    fi
    echo ""
fi