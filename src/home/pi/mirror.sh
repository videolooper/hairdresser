#!/bin/bash
HOST='ftp.webroom.it'
USER='FTP USER'
PASS='FTP PASSWORD'

TARGETFOLDER="/home/pi/tmp-videos"
SOURCEFOLDER="/"

LOGFTP="/home/pi/logs/ftp/$(date +'%Y-%m-%d').log"
LOGFTP=$LOGFTP

LOGRSYNC="/home/pi/logs/rsync/$(date +'%Y-%m-%d').log"
LOGRSYNC=$LOGRSYNC

UPDATEIMG="/home/pi/updating.png"

printf "\n###############################\n" >> $LOGFTP
printf "# script launched at $(date +'%T') #\n" >> $LOGFTP
printf "###############################\n" >> $LOGFTP
printf "\n" >> $LOGFTP

printf "mirroring files from remote server to tmp-videos:\n" >> $LOGFTP
lftp -e "
open $HOST
user $USER $PASS
set ssl:verify-certificate no
mirror --continue --parallel=10 --only-newer --delete --verbose=2 $SOURCEFOLDER $TARGETFOLDER
bye
" >> $LOGFTP
printf "\ndone.\n\n" >> $LOGFTP 

printf "\n###############################\n" >> $LOGRSYNC
printf "# script launched at $(date +'%T') #\n" >> $LOGRSYNC
printf "###############################\n" >> $LOGRSYNC
printf "\n" >> $LOGRSYNC

printf "stopping looper ...\n" >> $LOGRSYNC
sudo service videoloop stop >> $LOGRSYNC
printf " ...done\n\n" >> $LOGRSYNC

printf "removing logo overlay ..." >> $LOGRSYNC
sudo killall pngview >> $LOGRSYNC
printf " ...done\n\n" >> $LOGRSYNC

printf "removing logo overlay ..." >> $LOGRSYNC
sudo killall pngview >> $LOGRSYNC
printf " ...done\n\n" >> $LOGRSYNC

printf "showing 'update in progress' image ..." >> $LOGRSYNC
/home/pi/raspidmx-master/pngview/pngview -l 1 -x 0 -y 0 $UPDATEIMG &
printf " ...done\n\n" >> $LOGRSYNC

printf "synchronizing tmp-videos with videos folder:\n" >> $LOGRSYNC
rsync -avzh --delete /home/pi/tmp-videos/ /home/pi/videos >> $LOGRSYNC
printf "\ndone.\n\n" >> $LOGRSYNC

# rebooting for a fresh running machine :)
# sudo shutdown -r now

printf "removing 'update in progress' image ..." >> $LOGRSYNC
sudo killall pngview >> $LOGRSYNC
printf " ...done\n\n" >> $LOGRSYNC

printf "\nstarting looper..." >> $LOGRSYNC
sudo service videoloop start >> $LOGRSYNC &
printf " ...done\n\n" >> $LOGRSYNC
