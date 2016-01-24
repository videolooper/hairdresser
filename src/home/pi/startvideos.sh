#!/bin/bash

declare -A vids

#Make a newline a delimiter instead of a space
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

configs=`cat /boot/looperconfig.txt`
usb=`echo "$configs" | grep usb | cut -c 5- | tr -d '\r' | tr -d '\n'`
audio_source=`echo "$configs" | grep audio_source | cut -c 14- | tr -d '\r' | tr -d '\n'`
seamless=`echo "$configs" | grep seamless | cut -c 10- | tr -d '\r' | tr -d '\n'`

FILES=/home/pi/videos/
M3U=/home/pi/videos/playlist.m3u

if [[ $usb -eq 1 ]]; then
    FILES=/media/USB/videos/
fi

if [ -n "$seamless" ] && [[ ! "$seamless" -eq 0 ]]; then
    #run the seamless looper
    echo "seamless isn't 0"
    `/opt/vc/src/hello_pi/hello_video/hello_video.bin "$FILES$seamless"`
    exit 0
fi

current=0
if test -f "$M3U"; then
        # playlist file found: parsing playlist
        while IFS='' read -r video || [[ -n "$video" ]]; do
		# removing (mac/linux/windows) carriage return character
		video=`echo $video | sed $'s/\r//'`

                # filtering comment lines (starting with #)
                if [[ "$video" != \#* ]]; then

                        # trimming file path (mac/linux/windows)
                        video=${video##*[/|\\]}

                        # filtering by supported extensions
                        if [[ ${video##*.} =~ mp4|avi|mkv|mp3|mov|mpg|flv|m4v ]]; then

                                # checking for existing files in video folder
                                if test -f ${FILES}${video}; then
                                        vids[$current]="$video"
                                        let current+=1
				fi
                        fi
                fi

        done < $M3U
else
        # playlist file not found, parsing video directory's content
        for vid in `ls "$FILES" | egrep '\.(mp4|avi|mkv|mp3|mov|mpg|flv|m4v)$'`
        do
                vids[$current]="$vid"
                let current+=1
        done
fi
max=$current
# player will start from 1st video ($vids[0])
current=-1

#TEST: print actual, ordered playlist
#printf '%s\n' "${vids[@]}"
#exit 0

#Reset the IFS
IFS=$SAVEIFS

while true; do
if pgrep omxplayer > /dev/null
then
	echo 'running' > /dev/null
else
	let current+=1
	if [ $current -ge $max ]
	then
		current=0
	fi

	if pgrep pngview > /dev/null
	then
		/usr/bin/omxplayer --layer 0 -o "$audio_source" "$FILES${vids[$current]}"
	else
		# adding watermark over video(s)
		/home/pi/raspidmx-master/pngview/pngview -l 1 -x 1745 -y 1015 /home/pi/logo.png & /usr/bin/omxplayer --layer 0 -o "$audio_source" "$FILES${vids[$current]}"
	fi

	# echo "launching another instance"
fi
done

