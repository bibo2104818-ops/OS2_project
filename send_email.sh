#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

Subject="System Report"

while true
do

echo -e "${BLUE}====================================${NC}"
echo -e "${YELLOW}        Email Sender Menu${NC}"
echo -e "${BLUE}====================================${NC}"

echo -e "${GREEN}1) Send Email Report${NC}"
echo -e "${GREEN}2) Check Report File${NC}"
echo -e "${GREEN}3) Exit${NC}"

echo -e "${BLUE}====================================${NC}"

read -p "Choose option: " option

case $option in

1)
read -p "Enter destination email: " addr
read -p "Enter report full path: " rep

if [[ -z "$addr" || -z "$rep" ]]; then
echo "wrong input. Try again!"
exit 1
fi

if [[ ! "$addr" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
    echo -e "${RED}Invalid email address!${NC}"
    continue
fi


if [ -f "$rep" ]; then

# Send email with attachment
echo "Please find the report attached." | mutt -s "$Subject" -a "$rep" -- "$addr"

if [ $? -eq 0 ]; then
echo -e "${GREEN}Email sent successfully${NC}"
else
echo -e "${RED}Email sending failed${NC}"
fi

else
echo -e "${RED}Report file not found!${NC}"
fi
;;

2)
read -p "Enter report file name: " name

if [ -f "$name" ]; then
echo -e "${GREEN}File exists${NC}"
else
echo -e "${RED}File not found${NC}"
fi
;;

3)
echo -e "${YELLOW}Goodbye!${NC}"
exit 0
;;

*)
echo -e "${RED}Wrong option!${NC}"
;;

esac

echo ""
done
