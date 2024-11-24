#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati
# Fetch TikTok account details by username

clear

# Foreground Color
red="\e[31m"
green="\e[32m"
yellow="\e[33m"

# Text Format
normal="\e[0m"
bold="\e[1m"
faint="\e[2m"
italics="\e[3m"
underlined="\e[4m"

# Check dependencies
if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    echo -e "${red}Error: curl and jq are required but not installed. Please install them and try again.${normal}"
    exit 1
fi

# Display author info
clear
echo -e "${yellow}
   █████▒▓█████  ██▓     ▒█████   ███▄    █
 ▓██   ▒ ▓█   ▀ ▓██▒    ▒██▒  ██▒ ██ ▀█   █
 ▒████ ░ ▒███   ▒██░    ▒██░  ██▒▓██  ▀█ ██▒
 ░▓█▒  ░ ▒▓█  ▄ ▒██░    ▒██   ██░▓██▒  ▐▌██▒
 ░▒█░    ░▒████▒░██████▒░ ████▓▒░▒██░   ▓██░
  ▒ ░    ░░ ▒░ ░░ ▒░▓  ░░ ▒░▒░▒░ ░ ▒░   ▒ ▒
  ░       ░ ░  ░░ ░ ▒  ░  ░ ▒ ▒░ ░ ░░   ░ ▒░
  ░ ░       ░     ░ ░   ░ ░ ░ ▒     ░   ░ ░
            ░  ░    ░  ░    ░ ░           ░
${normal}"

echo -e "${faint}  Fetch TikTok account details by username.${normal}\n"
echo -e "           Author: Haitham Aouati"
echo -e "       GitHub: ${underlined}github.com/haithamaouati${normal}\n"

# Prompt for username
read -p "Enter the TikTok username: " username
echo -e "\nFetching ${yellow}@$username${normal} details...\n"

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
    echo -e "${faint}${bold}${underlined}Account Details:${normal}"
    echo -e "ID: ${yellow}$id${normal}"
    echo -e "Username: ${yellow}$uniqueId${normal}"
    echo -e "Nickname: ${yellow}$nickname${normal}"
    echo -e "Pfp: ${yellow}$avatarLarger${normal}"
    echo -e "Bio: ${yellow}$signature${normal}\n"

    echo -e "${faint}${bold}${underlined}Account Settings:${normal}"
    echo -e "Private Account: ${yellow}$privateAccount${normal}"
    echo -e "Secret: ${yellow}$secret${normal}"
    echo -e "Language: ${yellow}$language${normal}"
    echo -e "Region: ${yellow}$region${normal}\n"

    echo -e "${faint}${bold}${underlined}Statistics:${normal}"
    echo -e "Followers: ${yellow}$followerCount${normal}"
    echo -e "Following: ${yellow}$followingCount${normal}"
    echo -e "Likes: ${yellow}$heartCount${normal}"
    echo -e "Videos: ${yellow}$videoCount${normal}\n"
else
    echo -e "Failed to fetch account details. Please check the username or source code.${normal}"
fi
