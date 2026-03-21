#!/bin/bash
#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"



# input validation
REMOTE_USER=$1
REMOTE_IP=$2

if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_IP" ]; then 
    echo -e "\e[31mError: Missing target details.\e[0m"
    echo "Usage: ./remote_access.sh <username> <ip_address>"
    exit
fi
#Files & directory variables
HW_SCRIPT="hardware_info.sh"
SW_SCRIPT="software_info.sh"
REMOTE_RUN_DIR="/tmp/audit_run"
REMOTE_OUT_DIR="/tmp/sys_audit"
LOCAL_SAVE_DIR="./collected_report/${REMORE_IP}_$(date +%F)"

mkdir -p "$LOCAL_SAVE_DIR"

echo "Starting the Automated Remote Audit on $REMOTE_USER@$REMOTE_IP...."
# preparing and uploading
echo "Uploading AUdit scripts..."
ssh "$REMOTE_USER@$REMOTE_IP" mkdir -p "$REMOTE_RUN_DIR"
scp "$HW_SCRIPT" "$SW_SCRIPT" "$REMOTE_USER@$REMOTE_IP:$REMOTE_RUN_DIR/"
#Executing the scripts remotely and creating an integrity hash
echo "Running the audits on the remote machine...."
ssh "$REMOTE_USER@$REMOTE_IP" "cd $REMOTE_RUN_DIR && chmod +x $HW_SCRIPT $SW_SCRIPT && ./$HW_SCRIPT && ./$SW_SCRIPT && cd $REMOTE_OUT_DIR && sha256sum * > integrity_hashes.txt "
# downloading the reports
echo "Downloading the reports and hashes...."

scp -r "$REMOTE_USER@$REMOTE_IP:$REMOTE_OUT_DIR/"* "$LOCAL_SAVE_DIR"
#cleaning the remote machine
echo "cleaning up remote tracks...."
ssh "$REMOTE_USER@$REMOTE_IP" "rm -rf $REMOTE_RUN_DIR $REMOTE_OUT_DIR"
echo "\e[32m----Success! All reports have been saved locally to $LOCAL_SAVE_DIR----\e[0m"


