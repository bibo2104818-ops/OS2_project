#!/bin/bash
set -e

# Colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

echo -e "${BOLD}${CYAN}---- Installing SSH requirements ----${RESET}"

# Root check
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}${BOLD}Please run this script as root (use sudo).${RESET}"
    exit 1
fi

# Update package list
echo -e "${CYAN}Updating package lists...${RESET}"
apt update

# Install SSH client and server
echo -e "${CYAN}Installing OpenSSH client and server...${RESET}"
apt install -y openssh-client openssh-server

# Enable and start SSH service
echo -e "${CYAN}Enabling SSH service...${RESET}"
systemctl enable ssh

echo -e "${CYAN}Starting SSH service...${RESET}"
systemctl start ssh

# Check service status
if systemctl is-active --quiet ssh; then
    echo -e "${GREEN}SSH service is running successfully.${RESET}"
else
    echo -e "${RED}SSH service failed to start.${RESET}"
    exit 1
fi

# Show installed versions
echo -e "${CYAN}Installed versions:${RESET}"
ssh -V 2>&1 || true
sshd -V 2>&1 || true

# Optional firewall note
echo -e "${YELLOW}If you use a firewall, make sure port 22 is allowed.${RESET}"

echo -e "${GREEN}${BOLD}---- SSH installation complete ----${RESET}"