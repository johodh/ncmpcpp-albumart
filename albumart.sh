#!/bin/bash
# johodh 2020-02-01 

function reset_background
{
    printf "\e]20;;100x100+1000+1000\a"
}

# this argument clears the current picture
if test "$1" = "clear"; then
	reset_background
	exit 0
fi

# set your last.fm API key, where to store albumart etc.
source $HOME/.albumart-settings


function print_albumart
{
	convert ${ART_PATH}${ALBUM}.png -resize 400x $COVER
	if [[ -f "$COVER" ]] ; then
		printf "\e]20;${COVER};87x87+96+0:op=keep-aspect\a"
#		printf "\e]20;${COVER};95x95+100+0:op=keep-aspect\a"
	else 
		reset_background
	fi
}

URL="http://ws.audioscrobbler.com/2.0/?method=${METHOD}&artist=${ARTIST}&api_key=${API_KEY}&album=${ALBUM}&format=json"

if [[ -f "${ART_PATH}${ALBUM}.png" ]] ; then
	print_albumart
else
	RESPONSE=$(wget -qO- $URL)
	IMG_URL=$(echo ${RESPONSE} | grep -o '\"\#text\":"[a-Z/:\.0-9]*","size":"mega"' | awk -F '"' '{print $4}')
	if [[ -n $IMG_URL ]]; then 
		wget -qO ${ART_PATH}${ALBUM}.png $IMG_URL
		print_albumart
	else 
		reset_background
	fi
fi
