#!/bin/bash
# monitor_alert.sh — CPU & Memory Alert
# Usage: bash monitor_alert.sh [alert@email.com]

CPU_THRESHOLD=80
MEM_THRESHOLD=80
EMAIL="${1:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

send_alert() {
    local subject="$1" body="$2"
    echo -e "${RED}⚠ ALERT: $subject${NC}"
    echo "[$(date '+%F %T')] ALERT: $subject" >> ./monitor_alert.log
    [[ -n "$EMAIL" ]] && echo "$body" | mutt -s "$subject" -- "$EMAIL"
}

# CPU check
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk '{printf "%.0f", $1}')
echo "CPU: ${CPU}%"
(( CPU >= CPU_THRESHOLD )) && send_alert "High CPU Usage: ${CPU}%" \
"Host: $(hostname)
CPU Usage: ${CPU}% (threshold: ${CPU_THRESHOLD}%)
Time: $(date)

Top CPU processes:
$(ps aux --sort=-%cpu | head -6)"

# Memory check
MEM=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.0f", (t-a)*100/t}' /proc/meminfo)
echo "MEM: ${MEM}%"
(( MEM >= MEM_THRESHOLD )) && send_alert "High Memory Usage: ${MEM}%" \
"Host: $(hostname)
Memory Usage: ${MEM}% (threshold: ${MEM_THRESHOLD}%)
Time: $(date)

Top memory processes:
$(ps aux --sort=-%mem | head -6)"

echo -e "${GREEN}Done.${NC}"
