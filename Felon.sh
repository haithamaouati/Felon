#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati
# Fetch TikTok account region by username

clear

# Text format
BOLD="\e[1m"
UNDERLINE="\e[4m"
CLEAR="\e[0m"

# Text color
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
CYAN="\e[36m"

# Text color with bold font
RED_BOLD="\e[1;31m"
YELLOW_BOLD="\e[1;33m"

# Lines
NEW_LINE="\n"

# Author info
clear
echo -e "\n\n${YELLOW}$(figlet -f pagga.flf Felon)\n"
sleep 1
echo -e "${YELLOW_BOLD}$0 ${CLEAR}by Haitham Aouati"
echo -e " Fetch TikTok account region by username.\n"
echo -e "GitHub: ${UNDERLINE}github.com/haithamaouati${CLEAR}\n"

# Prompt for username
read -p "Enter the TikTok username: " username
echo -e "\nFetching ${YELLOW_BOLD}@$username${CLEAR} region..."

# Construct the URL
url="https://www.tiktok.com/@$username?isUniqueId=true&isSecured=true"

# Fetch the source code
source_code=$(curl -s "$url")

# Extract the second occurrence of the region value (region code)
region_code=$(echo "$source_code" | grep -o '"region":"[^"]*"' | sed -n '2p' | sed 's/"region":"//;s/"//')

# Check if region code was found
if [[ -n $region_code ]]; then
    # Search for the country in the JSON file based on the region code
    country_name=$(jq -r --arg region "$region_code" '.[] | select(.code == $region) | .name' countries.json)

    # Check if country name is found
    if [[ -n $country_name ]]; then
        echo -e "Region: ${YELLOW_BOLD}$country_name${CLEAR}\n"
    else
        echo -e "Country not found for region code: ${YELLOW_BOLD}$region_code${CLEAR}\n"
    fi
else
    echo -e "${RED}Region code not found. Please check the username or the source code.${CLEAR}\n"
fi
