#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' 
WHITE='\033[0;37m'

echo -e "${WHITE}===============================================${RESET}"

echo -e "\e[30m"
echo "  ██████  ███████     ██████  ██████   ██████       ██ ███████  ██████ ████████ "
echo " ██    ██ ██          ██   ██ ██   ██ ██    ██      ██ ██      ██         ██    "
echo " ██    ██ ███████     ██████  ██████  ██    ██      ██ █████   ██         ██    "
echo " ██    ██      ██     ██      ██   ██ ██    ██ ██   ██ ██      ██         ██    "
echo "  ██████  ███████     ██      ██   ██  ██████   █████  ███████  ██████    ██    "
echo "                                                                                "
echo "                     ██   ██ ████████  ██████   ██████  ██      ███████         "
echo "                     ██   ██    ██    ██    ██ ██    ██ ██      ██              "
echo "                     ███████    ██    ██    ██ ██    ██ ██      ███████         "
echo "                     ██   ██    ██    ██    ██ ██    ██ ██           ██         "
echo "                     ██   ██    ██     ██████   ██████  ███████ ███████         "
echo -e "\e[0m"
echo -e "${WHITE}=================================================${RESET}"

while true
do

    echo -e "${GREEN}1) Hardware Info${NC}"
    echo -e "${GREEN}2) Install${NC}"
    echo -e "${GREEN}3) Remote Access${NC}"
    echo -e "${GREEN}4) Run Script${NC}"
    echo -e "${GREEN}5) Send Email${NC}"
    echo -e "${GREEN}6) Setup SSH${NC}"
    echo -e "${GREEN}7) Software Info${NC}"
    echo -e "${GREEN}8) cron job manager{NC}"
    echo -e "${RED}0) Exit${NC}"

    echo -e "${CYAN}==============================${NC}"
    read -p "Choose an option: " choice

    case $choice in
        1)
            echo -e "${YELLOW}Running Hardware Info...${NC}"
            bash hardware_info.sh
            ;;
        2)
            echo -e "${YELLOW}Running Install...${NC}"
            bash install.sh
            ;;
        3)
            echo -e "${YELLOW}Running Remote Access...${NC}"
            bash remote_access.sh
            ;;
        4)
            echo -e "${YELLOW}Running Script...${NC}"
            bash run.sh
            ;;
        5)
            echo -e "${YELLOW}Sending Email...${NC}"
            bash send_email.sh
            ;;
        6)
            echo -e "${YELLOW}Setting up SSH...${NC}"
            bash setup_ssh.sh
            ;;
        7)
            echo -e "${YELLOW}Showing Software Info...${NC}"
            bash software_info.sh
            ;;

        8) echo -e "${YELLOW} running Script...${NC}"
           bash cron_script.sh
           ;;


        0)
            echo -e "${RED}Exiting...${NC}"

                  echo -e "${CYAN}"
   echo " ██████╗ ███████╗    ████████╗ ██████╗  ██████╗ ██╗     ███████╗"
   echo "██╔═══██╗██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝"
   echo "██║   ██║███████╗       ██║   ██║   ██║██║   ██║██║     ███████╗"
   echo "██║   ██║╚════██║       ██║   ██║   ██║██║   ██║██║     ╚════██║"
   echo "╚██████╔╝███████║       ██║   ╚██████╔╝╚██████╔╝███████╗███████║"
   echo " ╚═════╝ ╚══════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝"
   echo -e "${NC}"


            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac

    echo
done

