#!/bin/bash


#colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

    echo -e "${CYAN}"
    echo "  ██████╗ ██████╗  ██████╗ ██████╗ ███████╗"
    echo " ██╔════╝██╔═══██╗██╔════╝ ██╔══██╗██╔════╝"
    echo " ██║     ██║   ██║██║  ███╗██████╔╝█████╗  "
    echo " ██║     ██║   ██║██║   ██║██╔═══╝ ██╔══╝  "
    echo " ╚██████╗╚██████╔╝╚██████╔╝██║     ███████╗"
 echo -e "  ╚═════╝ ╚═════╝  ╚═════╝ ╚═╝     ╚══════╝${RESET}"
   echo -e  "        ${YELLOW}FILE COMPARISON TOOL${RESET}"
 echo -e "${CYAN}=========================================${RESET}"

looping=true

while "$looping"
do
    echo -e "${GREEN}Enter report1 full path name${RESET}"
    read rep1

    echo -e "${GREEN}Enter report2 full path name${RESET}"
    read rep2

    if [ -z "$rep1" ] || [ -z "$rep2" ]; then 
        echo -e "${RED}ERROR Enter file name${RESET}"
        continue
    fi


    if [ ! -f "$rep1" ]; then
        echo -e "${RED}File 1 not found. Searching...${RESET}"

        mapfile -t results1 < <(find . -type f -iname "*$(basename "$rep1")*" 2>/dev/null)

        if [ ${#results1[@]} -eq 0 ]; then
            echo -e "${RED}NO matches found.${RESET}"
            continue
        fi

        echo -e "${YELLOW}Select the correct file:${RESET}"
        select choice1 in "${results1[@]}"; do
            if [ -n "$choice1" ]; then
                rep1="$choice1"
                break
            else
                echo -e "${RED}Invalid choice${RESET}"
            fi
        done
    fi

    
    if [ ! -f "$rep2" ]; then 
        echo -e "${RED}File 2 not found. Searching...${RESET}"

        mapfile -t results2 < <(find . -type f -iname "*$(basename "$rep2")*" 2>/dev/null)

        if [ ${#results2[@]} -eq 0 ]; then
            echo -e "${RED}NO matches found.${RESET}"
            continue
        fi

        echo -e "${YELLOW}Select the correct file:${RESET}"
        select choice2 in "${results2[@]}"; do
            if [ -n "$choice2" ]; then
                rep2="$choice2"   
                break
            else
                echo -e "${RED}Invalid choice${RESET}"
            fi
        done
    fi

  
    if [ -f "$rep1" ] && [ -f "$rep2" ]; then
        echo -e "${CYAN}Searching for files completed ✅${RESET}"
        looping=false
    else
        echo -e "${YELLOW}Try again.${RESET}"
    fi

done


echo -e "${CYAN}What do you want to do?${RESET}"
echo "1) Compare files"
echo "2) Check if identical"
echo "3) Show stats"
echo "4) Search inside files"
read -p "Choose option: " choice

case "$choice" in
    1) diff -u "$rep1" "$rep2" ;;
    
    2) if cmp -s "$rep1" "$rep2";then
      echo -e "${GREEN}Files are identical ✅${RESET}"
       else
         echo -e "${RED} Files are different ❌${RESET}"
    fi
    ;;

    3)
     echo "File1 lines: $(wc -l < "$rep1")"
     echo "File2 lines: $(wc -l < "$rep2")"
    ;;
        
    4)
     
     read -p "Enter keyword: " keyword
     grep -i "$keyword" "$rep1" "$rep2"
    ;;

    *)
    echo "Invalid option"
    ;;
      
esac

echo -e "${CYAN}"
echo "  ██████╗  ██████╗  ██████╗ ██████╗ ██████╗ "
echo " ██╔════╝ ██╔═══██╗██╔════╝ ██╔══██╗██╔══██╗"
echo " ██║  ███╗██║   ██║██║  ███╗██████╔╝██████╔╝"
echo " ██║   ██║██║   ██║██║   ██║██╔═══╝ ██╔═══╝ "
echo " ╚██████╔╝╚██████╔╝╚██████╔╝██║     ██║     "
echo "  ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝     ╚═╝     "
echo -e "${YELLOW}"
echo "               GOODBYE 👋"
echo -e "${RESET}"


