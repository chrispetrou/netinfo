#!/usr/bin/env bash

# change that based on your network interface...
iface='en0'
eth='ether'
NC='\033[0m'
BG='\033[1;32m'
FG='\033[0;32m'
FR='\033[1;31m'
BW='\033[1;97m'

# check for bash version - snippet taken from:
# https://askubuntu.com/questions/916976/bash-one-liner-to-check-if-version-is
version_above_4(){
    # check if $BASH_VERSION is set at all
    [ -z $BASH_VERSION ] && return 1

    # If it's set, check the version
    case $BASH_VERSION in 
        4.*) return 0 ;;
        ?) return 1;; 
    esac
}

if [ -x "$(version_above_4)" ]; then
    echo -e "\n${BW}[${FR}x${NC}${BW}] bash${NC} ${FR}version 4.*${NC} is required..." >&2
    echo -e "To update to version 4 on mac: ${FR}brew update && brew install bash${NC}\n" >&2
    exit 1
fi

# check if airport is linked - else exit
if ! [ -x "$(command -v airport)" ]; then
  echo '[x] airport symbolic link not found!' >&2
  exit 1
fi

# obtain public ip
public=$(curl -s https://api.ipify.org)

# obtain basic LAN info
# assumes that private ip starts with 192.168.
info() {
    route -n get default | grep gateway && ifconfig $iface \
    | grep 192.168. && ifconfig $iface | grep $eth
}

apinfo() {
    airport -I | grep SSID
}

AP=$(apinfo)
SSID=$(echo $AP | awk '{ print $2; }')
access_point=$(echo $AP | awk '{ print $4; }')

LAN_info=$(info)
mac=$(echo $LAN_info | awk '{ print $10; }')
gateway=$(echo $LAN_info | awk '{ print $2; }')
local_ip=$(echo $LAN_info | awk '{ print $4; }')

declare -A data
data=( ["Gateway"]="$gateway" ["Mac"]="$mac" ["Public IP"]="$public" 
    ["Private IP"]="$local_ip" ["Access Point"]="$access_point"  ["SSID"]="$SSID" )

# print information...
echo     "┌════════════════════════════════┐"
echo -e "█          ${BG}Network Info${NC}          █"
echo     "└════════════════════════════════┘"
for item in "${!data[@]}";
    do
        sp=$((15-${#item}))
        result=$( printf "%${sp}s" ' ' )
        spaces=${result// / }
        echo -e "${BG}•${NC} ${BW}$item:$spaces${NC}${FG}${data[$item]}${NC}"; 
    done
#_EOF