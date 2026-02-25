#!/bin/bash
output_file="output/temp/hardware_info.txt"
mkdir -p output/temp

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

echo "Model: $model" >> "$output_file"
echo "Vendor: $vendor" >> "$output_file"
echo "Architecture: $arch" >> "$output_file"
echo "CPU Family: $family" >> "$output_file"
echo "Cores per Socket: $cores" >> "$output_file"
echo "Threads per Core: $threads" >> "$output_file"
echo "Total Threads: $(nproc)" >> "$output_file"
echo "Max MHz: $max_mhz" >> "$output_file"
echo "" >> "$output_file"