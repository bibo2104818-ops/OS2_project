#!/bin/bash
# this script will handle script scheduling and hide cron complexity from the user

# colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
WHITE="\e[97m"
BOLD="\e[1m"
RESET="\e[0m"

# needed directories
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
HARDWARE_SCRIPT="$BASE_DIR/hardware_info.sh"
SOFTWARE_SCRIPT="$BASE_DIR/software_info.sh"

print_msg() {
    echo -e "$1"
}

pause() {
    read -p "Press Enter to continue...."
}

is_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

valid_minute() {
    is_number "$1" && [ "$1" -ge 0 ] && [ "$1" -le 59 ]
}

valid_hour() {
    is_number "$1" && [ "$1" -ge 0 ] && [ "$1" -le 23 ]
}

valid_weekday() {
    is_number "$1" && [ "$1" -ge 0 ] && [ "$1" -le 6 ]
}

valid_month() {
    is_number "$1" && [ "$1" -ge 1 ] && [ "$1" -le 12 ]
}

get_max_days() {
    case "$1" in
        1|3|5|7|8|10|12) echo 31 ;;
        4|6|9|11) echo 30 ;;
        2) echo 29 ;;
        *) echo 0 ;;
    esac
}

valid_day_for_month() {
    local day="$1"
    local month="$2"
    local max_days

    if ! is_number "$day"; then
        return 1
    fi

    max_days=$(get_max_days "$month")
    [ "$day" -ge 1 ] && [ "$day" -le "$max_days" ]
}

check_script() {
    local script_path="$1"

    if [ ! -f "$script_path" ]; then
        print_msg "${RED}Script not found: $script_path${RESET}"
        return 1
    fi

    if [ ! -x "$script_path" ]; then
        print_msg "${YELLOW}Script is not executable. Adding permission...${RESET}"
        chmod +x "$script_path" || {
            print_msg "${RED}Failed to make the script executable.${RESET}"
            return 1
        }
    fi

    return 0
}

choose_script() {
    while true; do
        print_msg "${BOLD}${CYAN}Choose script to schedule:${RESET}"
        echo "1) hardware_info.sh"
        echo "2) software_info.sh"
        echo "3) Enter custom script path"
        read -p "Choice: " script_choice

        case "$script_choice" in
            1)
                SELECTED_SCRIPT="$HARDWARE_SCRIPT"
                break
                ;;
            2)
                SELECTED_SCRIPT="$SOFTWARE_SCRIPT"
                break
                ;;
            3)
                read -p "Enter full script path: " custom_path
                SELECTED_SCRIPT="$custom_path"
                break
                ;;
            *)
                print_msg "${RED}Invalid choice. Try again.${RESET}"
                ;;
        esac
    done

    check_script "$SELECTED_SCRIPT" || return 1
    SELECTED_SCRIPT="$(realpath "$SELECTED_SCRIPT")"
    return 0
}

add_cron_job() {
    local cron_job="$1"

    if crontab -l 2>/dev/null | grep -Fq "$cron_job"; then
        print_msg "${YELLOW}This cron job already exists.${RESET}"
        return 0
    fi

    (crontab -l 2>/dev/null; echo "$cron_job") | crontab -

    if [ $? -eq 0 ]; then
        print_msg "${GREEN}Cron job added successfully.${RESET}"
        echo "$cron_job"
    else
        print_msg "${RED}Failed to add cron job.${RESET}"
    fi
}

schedule_daily() {
    read -p "Enter hour (0-23): " hour
    read -p "Enter minute (0-59): " minute

    if ! valid_hour "$hour" || ! valid_minute "$minute"; then
        print_msg "${RED}Invalid hour or minute.${RESET}"
        return
    fi

    cron_job="$minute $hour * * * $SELECTED_SCRIPT"
    add_cron_job "$cron_job"
}

schedule_weekly() {
    read -p "Enter hour (0-23): " hour
    read -p "Enter minute (0-59): " minute
    echo "Weekdays: 0=Sunday, 1=Monday, 2=Tuesday, 3=Wednesday, 4=Thursday, 5=Friday, 6=Saturday"
    read -p "Enter weekday (0-6): " weekday

    if ! valid_hour "$hour" || ! valid_minute "$minute" || ! valid_weekday "$weekday"; then
        print_msg "${RED}Invalid input.${RESET}"
        return
    fi

    cron_job="$minute $hour * * $weekday $SELECTED_SCRIPT"
    add_cron_job "$cron_job"
}

schedule_monthly() {
    read -p "Enter month (1-12): " month
    read -p "Enter day of month: " day
    read -p "Enter hour (0-23): " hour
    read -p "Enter minute (0-59): " minute

    if ! valid_month "$month"; then
        print_msg "${RED}Invalid month. Please enter a value from 1 to 12.${RESET}"
        return
    fi

    if ! valid_day_for_month "$day" "$month"; then
        max_days=$(get_max_days "$month")
        print_msg "${RED}Invalid day for month $month. Maximum is $max_days.${RESET}"
        return
    fi

    if ! valid_hour "$hour" || ! valid_minute "$minute"; then
        print_msg "${RED}Invalid hour or minute.${RESET}"
        return
    fi

    cron_job="$minute $hour $day $month * $SELECTED_SCRIPT"
    add_cron_job "$cron_job"
}

schedule_every_reboot() {
    cron_job="@reboot $SELECTED_SCRIPT"
    add_cron_job "$cron_job"
}

list_jobs() {
    print_msg "${BOLD}${CYAN}Current cron jobs:${RESET}"
    crontab -l 2>/dev/null || print_msg "${YELLOW}No cron jobs found.${RESET}"
}

remove_job() {
    current_jobs="$(crontab -l 2>/dev/null)"

    if [ -z "$current_jobs" ]; then
        print_msg "${YELLOW}No cron jobs to remove.${RESET}"
        return
    fi

    print_msg "${BOLD}${CYAN}Current cron jobs:${RESET}"
    nl -w2 -s'. ' <<< "$current_jobs"

    read -p "Enter the number of the job to remove: " job_number

    if ! is_number "$job_number"; then
        print_msg "${RED}Invalid number.${RESET}"
        return
    fi

    new_jobs="$(echo "$current_jobs" | sed "${job_number}d")"

    if [ -z "$new_jobs" ]; then
        crontab -r
    else
        echo "$new_jobs" | crontab -
    fi

    if [ $? -eq 0 ]; then
        print_msg "${GREEN}Cron job removed successfully.${RESET}"
    else
        print_msg "${RED}Failed to remove cron job.${RESET}"
    fi
}

main_menu() {
    while true; do
        clear
        print_msg "${BOLD}${GREEN}===== Script Scheduler =====${RESET}"
        echo "1) Schedule script daily"
        echo "2) Schedule script weekly"
        echo "3) Schedule script monthly"
        echo "4) Schedule script at every reboot"
        echo "5) List scheduled jobs"
        echo "6) Remove a cron job"
        echo "7) Exit"
        echo

        read -p "Choose an option: " choice
        echo

        case "$choice" in
            1)
                choose_script && schedule_daily
                pause
                ;;
            2)
                choose_script && schedule_weekly
                pause
                ;;
            3)
                choose_script && schedule_monthly
                pause
                ;;
            4)
                choose_script && schedule_every_reboot
                pause
                ;;
            5)
                list_jobs
                pause
                ;;
            6)
                remove_job
                pause
                ;;
            7)
                print_msg "${GREEN}Goodbye.${RESET}"
                exit 0
                ;;
            *)
                print_msg "${RED}Invalid option. Try again.${RESET}"
                pause
                ;;
        esac
    done
}

main_menu