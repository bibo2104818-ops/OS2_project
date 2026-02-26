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
output_file="output/temp/hardware_info.txt"
mkdir -p output/temp
> "$output_file" #clear old content

clear

#Date and time
curent_time=$(date +"%Y-%m-%d %H:%M:%S")
echo -e "${BOLD}${CYAN}Hardware Info Scsan - $curent_time${RESET}"
echo -e "Hardware infoo Scan - $curent_time" >> "$output_file"

#BANNER
echo -e "${BOLD}${CYAN}"
echo " _   _               _                          ___        __       "  
echo "| | | | __ _ _ __ __| |_      ____ _ _ __ ___  |_ _|_ __  / _| ___  "
echo "| |_| |/ _\` | '__/ _\` \\ \\ /\\ / / _\` | '__/ _ \\  | || '_ \\| |_ / _ \\"
echo "|  _  | (_| | | | (_| |\\ V  V / (_| | | |  __/  | || | | |  _| (_) |"
echo "|_| |_|\__,_|_|  \__,_| \\_/\\_/ \__,_|_|  \___| |___|_| |_|_|  \___/ "
echo -e "${RESET}"
echo -e "${CYAN}Collecting Hardware information...${RESET}"

#Ask the user if they want to save the output to a file
read -p "Do you want to save the output to a file? (y/n) " output_choice
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
    if [[ "$output_choice" == "y" || "$output_choice" == "Y" ]]; then
       echo -e "$text" >> "$output_file"  
    fi
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

print_save "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

# CPU INFORMATION
echo "---- CPU Information ----" >> "$output_file"

cpu_info=$(lscpu)

model=$(echo "$cpu_info" | awk -F ':' '/Model name/ {print $2}' | xargs)
vendor=$(echo "$cpu_info" | awk -F ':' '/Vendor ID/ {print $2}' | xargs)
arch=$(echo "$cpu_info" | awk -F ':' '/Architecture/ {print $2}' | xargs)
family=$(echo "$cpu_info" | awk -F ':' '/CPU family/ {print $2}' | xargs)
cores=$(echo "$cpu_info" | awk -F ':' '/Core\(s\) per socket/ {print $2}' | xargs)
threads=$(echo "$cpu_info" | awk -F ':' '/Thread\(s\) per core/ {print $2}' | xargs)
max_mhz=$(echo "$cpu_info" | awk -F ':' '/CPU max MHz/ {print $2}' | xargs)
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
disk_info=$(df -h / /home 2>/dev/null)
#uptime:
uptime=$(uptime -p)
#Network interfaces & IP addresses
network_interfaces() {
    ip -o -4 addr show | awk '{print $2, $4}' | while read -r interfaces Ip; do
    print_save "${WHITE}Interface:${RESET} $interface"
    print_save "${WHITE}IPv4:${RESET} $Ip"
    done
}

print_save "${BOLD}${CYAN}Uptime:${RESET} $uptime"
print_save "${BOLD}${CYAN}---- GPU Information ----${RESET}"
print_save "${WHITE}GPU:${RESET} $gpu"
print_save "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
print_save "${BOLD}${CYAN}---- Disk Information ----${RESET}"
print_save "$disk_info"
print_save "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
print_save "${BOLD}${CYAN}---- RAM Information ----${RESET}"
print_save "${WHITE}Total Memory:${RESET}$MEM_TOTAL"
print_save "${WHITE}Memory Used:${RESET}$MEM_USED"
print_save "${WHITE}Free Memory:${RESET}$MEM_FREE"
print_save "${WHITE}Swap Total${RESET}$SWAP_TOTAL"
print_save "${WHITE}Swap Used:${RESET}$SWAP_USED"
print_save "${WHITE}Swap Free:${RESET}$SWAP_FREE"
print_save "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
print_save "${BOLD}${CYAN}---- CPU Information ----${RESET}"
print_save "${WHITE}Model:${RESET} $model" 
print_save "${WHITE}Vendor:${RESET} $vendor" 
print_save "${WHITE}Architecture:${RESET} $arch"
print_save "${WHITE}CPU Family:${RESET} $family" 
print_save "${WHITE}Cores per Socket:${RESET} $cores" 
print_save "${WHITE}Threads per Core:${RESET} $threads" 
print_save "${WHITE}Total Threads:${RESET} $(nproc)" 
print_save "${WHITE}Max MHz:${RESET} $max_mhz" 
print_save "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
print_save "${BOLD}${CYAN}---- Network Interface: ----${RESET}"
network_interfaces


print_save "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
print_save "${BOLD}${CYAN}Scan Completed Successfully.${RESET}"
