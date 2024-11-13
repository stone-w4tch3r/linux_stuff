#!/usr/bin/env python3

import csv
import subprocess
import time
from datetime import datetime

log_file_path = "/home/user1/memory_swap_log.csv"
max_lines = 1000  # Set the maximum number of lines allowed in the log

# Write the header to the plaintext file if it doesn't exist
with open(log_file_path, mode='w') as file:
    header = "Timestamp,MemTotal,MemUsed,MemFree,MemShared,MemBuff/Cache,MemAvailable,SwapTotal,SwapUsed,SwapFree"
    print(header)
    file.write(header + "\n")


# Function to parse memory and swap information from the `free` command
def parse_memory_info():
    result = subprocess.run(['free', '-m'], capture_output=True, text=True)
    lines = result.stdout.splitlines()

    memory_info = []
    # Select lines containing "Mem" and "Swap"
    for line in lines:
        if line.startswith("Mem") or line.startswith("Swap"):
            memory_info.append(line.split()[1:])

    return memory_info


# Function to trim the log file to maintain the maximum number of lines
def trim_log_file():
    with open(log_file_path, 'r') as file:
        lines = file.readlines()

    # If the number of lines exceeds the maximum, trim from the top
    if len(lines) > max_lines:
        with open(log_file_path, 'w') as file:
            file.writelines(lines[-max_lines:])  # Keep the last 'max_lines' entries


# Infinite loop to log memory and swap information
try:
    while True:
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        memory_info = parse_memory_info()

        # Prepare log entry
        mem_total, mem_used, mem_free, mem_shared, mem_buff_cache, mem_available = memory_info[0][0:6]
        swap_total, swap_used, swap_free = memory_info[1][0:3]
        log_entry = [
            timestamp,
            mem_total,
            mem_used,
            mem_free,
            mem_shared,
            mem_buff_cache,
            mem_available,
            swap_total,
            swap_used,
            swap_free
        ]

        # Write the log entry to the CSV file
        with open(log_file_path, mode='a', newline='') as file:
            file.write(",".join(log_entry) + "\n")

        # Trim the log file to maintain the line limit
        trim_log_file()

        print(",".join(log_entry))  # Output the log entry
        time.sleep(1)  # Sleep for 1 second
except KeyboardInterrupt:
    pass  # Handle the termination of the script gracefully
