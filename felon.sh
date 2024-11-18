#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati
# Fetch TikTok account details by username

clear

# Text format and colors
BOLD="\e[1m"
UNDERLINE="\e[4m"
CLEAR="\e[0m"
YELLOW_BOLD="\e[1;33m"
RED_BG="\e[41m"

# Check dependencies
if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    echo -e "${RED_BG}Error: figlet curl and jq are required but not installed. Please install them and try again.${CLEAR}"
    exit 1
fi

# Display author info
clear

echo -e "${YELLOW_BOLD}
    ⠀⠀⠀⠀⢀⣀⣤⣤⣤⣤⣄⡀⠀⠀⠀⠀
    ⠀⢀⣤⣾⣿⣾⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀
    ⢠⣾⣿⢛⣼⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡀
    ⣾⣯⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧
    ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
    ⣿⡿⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠻⢿⡵
    ⢸⡇ v⠉⠛⠛⣿⣿⠛⠛⠉2⠀⣿⡇
    ⢸⣿⣀⠀⢀⣠⣴⡇⠹⣦⣄⡀⠀⣠⣿⡇
    ⠈⠻⠿⠿⣟⣿⣿⣦⣤⣼⣿⣿⠿⠿⠟⠀
    ⠀⠀⠀⠀⠸⡿⣿⣿⢿⡿⢿⠇⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠈⠁⠈⠁⠀⠀⠀⠀⠀⠀
${CLEAR}"

echo -e "${YELLOW_BOLD}$(figlet -f standard Felon)"
echo -e "${YELLOW_BOLD} Felon ${CLEAR}by Haitham Aouati"
echo -e " Fetch TikTok account details by username.\n"
echo -e "GitHub: ${UNDERLINE}github.com/haithamaouati${CLEAR}\n"

# Prompt for username
read -p "Enter the TikTok username: " username
echo -e "\nFetching ${YELLOW_BOLD}@$username${CLEAR} details...\n"

# Construct the URL
url="https://www.tiktok.com/@$username?isUniqueId=true&isSecured=true"

# Fetch the source code
source_code=$(curl -s "$url")

# Extract values using jq
id=$(echo "$source_code" | grep -oP '"id":"\d+"' | head -n 1 | sed 's/"id":"//;s/"//')
uniqueId=$(echo "$source_code" | grep -oP '"uniqueId":"[^"]*"' | head -n 1 | sed 's/"uniqueId":"//;s/"//')
nickname=$(echo "$source_code" | grep -oP '"nickname":"[^"]*"' | head -n 1 | sed 's/"nickname":"//;s/"//')
avatarLarger=$(echo "$source_code" | grep -oP '"avatarLarger":"[^"]*"' | head -n 1 | sed 's/"avatarLarger":"//;s/"//')
signature=$(echo "$source_code" | grep -oP '"signature":"[^"]*"' | head -n 1 | sed 's/"signature":"//;s/"//')

privateAccount=$(echo "$source_code" | grep -oP '"privateAccount":[^,]*' | head -n 1 | sed 's/"privateAccount"://')
secret=$(echo "$source_code" | grep -oP '"secret":[^,]*' | head -n 1 | sed 's/"secret"://')
language=$(echo "$source_code" | grep -oP '"language":"[^"]*"' | head -n 1 | sed 's/"language":"//;s/"//')
region_code=$(echo "$source_code" | grep -o '"region":"[^"]*"' | sed -n '2p' | sed 's/"region":"//;s/"//')

followerCount=$(echo "$source_code" | grep -oP '"followerCount":[^,]*' | head -n 1 | sed 's/"followerCount"://')
followingCount=$(echo "$source_code" | grep -oP '"followingCount":[^,]*' | head -n 1 | sed 's/"followingCount"://')
heartCount=$(echo "$source_code" | grep -oP '"heartCount":[^,]*' | head -n 1 | sed 's/"heartCount"://')
videoCount=$(echo "$source_code" | grep -oP '"videoCount":[^,]*' | head -n 1 | sed 's/"videoCount"://')

if [[ -n $region_code ]]; then
    # Match region code to country name
    country_name=$(jq -r --arg region "$region_code" '.[] | select(.code == $region) | .name' countries.json)
    if [[ -n $country_name ]]; then
        region="$country_name"
    else
        region="Unknown (Code: $region_code)"
    fi
else
    region="Not Found"
fi

# Display extracted data
if [[ -n $id ]]; then
    echo -e "${BOLD}${UNDERLINE}Account Details:${CLEAR}"
    echo -e "ID: ${YELLOW_BOLD}$id${CLEAR}"
    echo -e "Username: ${YELLOW_BOLD}$uniqueId${CLEAR}"
    echo -e "Nickname: ${YELLOW_BOLD}$nickname${CLEAR}"
    echo -e "Pfp: ${YELLOW_BOLD}$avatarLarger${CLEAR}"
    echo -e "Bio: ${YELLOW_BOLD}$signature${CLEAR}\n"

    echo -e "${BOLD}${UNDERLINE}Account Settings:${CLEAR}"
    echo -e "Private Account: ${YELLOW_BOLD}$privateAccount${CLEAR}"
    echo -e "Secret: ${YELLOW_BOLD}$secret${CLEAR}"
    echo -e "Language: ${YELLOW_BOLD}$language${CLEAR}"
    echo -e "Region: ${YELLOW_BOLD}$region${CLEAR}\n"

    echo -e "${BOLD}${UNDERLINE}Statistics:${CLEAR}"
    echo -e "Followers: ${YELLOW_BOLD}$followerCount${CLEAR}"
    echo -e "Following: ${YELLOW_BOLD}$followingCount${CLEAR}"
    echo -e "Likes: ${YELLOW_BOLD}$heartCount${CLEAR}"
    echo -e "Videos: ${YELLOW_BOLD}$videoCount${CLEAR}\n"
else
    echo -e "${RED_BG}Failed to fetch account details. Please check the username or source code.${CLEAR}"
fi
