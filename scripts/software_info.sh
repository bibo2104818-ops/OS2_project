#!/bin/bash
output_file="output/software_info.txt"
#create the output directory if it does not exist
mkdir -p output

echo "======================" > "$output_file"
echo " SOFTWARE INFORMATION " >> "$output_file"
echo "======================" > "$output_file"

#Operating system information
echo " ---- Operating System Information ----" >> "$output_file"

if [ -f /etc/os-release ]; then
    source /etc/os-release
    echo "OS Name: $NAME" >> "$output_file"
    echo "OS Version: $VERSION" >> "$output_file"
    echo "Distribution ID: $ID" >> "$output_file"
fi

echo "Kernel Version: $(uname -r)" >> "$output_file"
echo "Kernel Architecture: $(uname -m)" >> "$output_file"
echo "Hostname: $(hostname)" >> "$output_file"
echo "" >> "$output_file"

#System uptime
echo "---- System Uptime ----" >> "$output_file"
echo "Uptime: $(uptime -p)" >> "$output_file" # -p (pretty)
echo "" >> "$output_file"

#Installed Packages
if command -v dpkg >/dev/null 2>&1; then
    echo "Package Manager : dpkg (Debian/Ubuntu)" >> "$output_file"
    echo "Total installed packages : $(dpkg -l |  wc -l)" >> "$output_file"
elif command -v rpm >/dev/null 2>&1; then
    echo "Package Manager : rpm (RedHat/CentOS)" >> "$output_file"
    echo "Totsl installed packages : $(rpm -qa | wc -l)" >> "$output_file"
else
    echo "Package Manager : Unknown" >> "$output_file"
fi
echo "" >> "$output_file"
#Running Services
echo "---- Installed Packages ----" >> "$output_file"

if command -v systemctl >/dev/null 2>&1; then # command -v searches for the command in $PATH and it returns an exit status
    echo "Active services: $(systemctl list-units --type=service --state=running | wc -l)" >> "$output_file"
else
    echo "Service Manager not detected." >> "$output_file"
fi 
echo "" >> "$output_file"

#Logged In Users
echo "---- Logged In Users ----" >> "$output_file"
echo "Current Users : " >> "$output_file"
echo "Logged in Users: $(users)" >> "$output_file"
echo "" >> "$output_file"

#Environment Information 
echo "---- Environment Information ----" >> "$output_file"
echo "Current User : $(whoami)" >> "$output_file"
echo "Shell : $SHELL" >> "$output_file"
echo "Home Directory : $HOME" >> "$output_file"
echo "" >> "$output_file"
