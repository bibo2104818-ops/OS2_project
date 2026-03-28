#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' 
WHITE='\033[0;37m'


program(){ 

 loop=true

 while $loop
 do

    echo -e "${BLUE}Choose one option${NC}"
    echo -e "${WHITE} _____________________________${NC}"
    echo -e "${WHITE}| ${GREEN}1) Hardware Info${NC}            |"
    echo -e "${WHITE}| ${GREEN}2) Install${NC}                  |"
    echo -e "${WHITE}| ${GREEN}3) Remote Access${NC}            |"
    echo -e "${WHITE}| ${GREEN}4) Run Script${NC}               |"
    echo -e "${WHITE}| ${GREEN}5) Send Email${NC}               |"
    echo -e "${WHITE}| ${GREEN}6) Setup SSH${NC}                |"
    echo -e "${WHITE}| ${GREEN}7) Software Info${NC}            |"
    echo -e "${WHITE}| ${GREEN}8) cron job manager${NC}         |" 
    echo -e "${WHITE}| ${GREEN}9) comparing two reports${NC}    |"
    echo -e "${WHITE}| ${RED}10) Exit${NC}                    |"
    echo -e "${WHITE}| ${BLUE}0) Go back to the main menu${NC} |"
    echo -e "${WHITE}|_____________________________|${NC}"

    echo -e "${CYAN}==============================${NC}"
    read -p "Choose an option: " choice

    case $choice in
        1)
            echo -e "${YELLOW}Running Hardware Info...${NC}"
            sudo bash hardware_info.sh
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
            sudo bash software_info.sh
            ;;

        8) echo -e "${YELLOW} running Script...${NC}"
           bash cron_script.sh
           ;;

        9)
           echo -e "Running Script....${NC}"
 
           bash comparing_report.sh
        ;;

        10)
            echo -e "${RED}Exiting...${NC}"

                interface

            exit 0
            ;;

        0)
        clear
         main_menu
         ;;

        *)
            echo -e "${RED}Invalid option!${NC}"
            ;;
    esac

    echo -e "${YELLOW} Do you want to chose other tool"
    echo    "1) YES"
    echo -e "2) NO${NC}"

     read ch

     case $ch in 

    1)
     loop=true
    ;;

    2) 
     loop=false
     interface
    ;;

    *) 
     echo -e "${RED}Invalid option the script will stop${NC}"
     loop=false
     interface
    ;;

    esac

 done

}


show_project_info(){
    echo -e "${CYAN}======================================${NC}"
    echo -e "${GREEN}        WELCOME $(whoami) TO MY TOOLKIT         ${NC}"
    echo -e "${CYAN}======================================${NC}"
    echo -e "${YELLOW}This project is a modular Bash toolkit that can:"
    echo "- Show hardware info"
    echo "- Install software or dependencies"
    echo "- Manage remote access and SSH"
    echo "- Run custom scripts"
    echo "- Send emails safely"
    echo "- Compare reports"
    echo "- Manage cron jobs"
    echo -e "${CYAN}Developed by:${NC}"
    echo -e "${GREEN}Lahlouh AbdElJalil${NC} and ${GREEN}Imad Taibi${NC}, students at the National School of Cybersecurity"
    echo -e "${BLUE}Check out our project page: https://github.com/bibo2104818-ops/OS2_project"
    echo -e "${YELLOW} Do you want to open link"
    echo    "1) YES"
    echo -e "2) NO${NC}"
    read ch1
    case $ch1 in 
    
    1)
      xdg-open https://github.com/bibo2104818-ops/OS2_project
      ;;
    2)
    ;;
    *)
    echo -e "${RED}Invalid option${NC}"
    ;; 
 esac

    read -p "Press Enter to continue to the main menu..."
    program
    clear
    
}

interface(){

                echo -e "${CYAN}"
   echo " ██████╗ ███████╗    ████████╗ ██████╗  ██████╗ ██╗     ███████╗"
   echo "██╔═══██╗██╔════╝    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝"
   echo "██║   ██║███████╗       ██║   ██║   ██║██║   ██║██║     ███████╗"
   echo "██║   ██║╚════██║       ██║   ██║   ██║██║   ██║██║     ╚════██║"
   echo "╚██████╔╝███████║       ██║   ╚██████╔╝╚██████╔╝███████╗███████║"
   echo " ╚═════╝ ╚══════╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝"
   echo -e "${NC}"
   echo -e "${YELLOW}/-------------GOODBYE------------\ ${NC}"

}

main_menu(){ 

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







 #---small information about the user that use this script-----

 echo -e "${CYAN}========== User Information ==========${NC}"

 echo -e "${GREEN}Username: ${NC}$(whoami)"

 echo -e "${GREEN}UID: ${NC}$(id -u)  GID: ${NC}$(id -g)"

 echo -e "${GREEN}Groups: ${NC}$(id -Gn)" 

 echo -e "${GREEN}Hostname: ${NC}$(hostname)"

 if [ -f /etc/os-release ]; then
    OS_NAME=$(grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
    echo -e "${GREEN}Operating System: ${NC}${OS_NAME}"
 fi

 echo -e "${GREEN}Home Directory: ${NC}$HOME"

 echo -e "${GREEN}Shell: ${NC}$SHELL"

 echo -e "${CYAN}=====================================${NC}"



 echo -e "${CYAN}Do you want to see project information or go directly to the program?${NC}"
 echo -e "${GREEN}1) Show project information${NC}"
 echo -e "${GREEN}2) Skip to main menu${NC}"

 read -p "Choose an option: " pre_choice
 case $pre_choice in 
    1)
        show_project_info
        ;;
    2)
        echo -e "${YELLOW}Skipping to main menu...${NC}"
        program
        ;;
    *)
        echo -e "${RED}Invalid option, continuing to main menu...${NC}"
        program
        ;;
 esac

}


main_menu
