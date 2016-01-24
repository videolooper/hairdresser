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
" >> $LOGFTP && printf "\ndone.\n\n" >> $LOGFTP 

printf "\n###############################\n" >> $LOGRSYNC
printf "# script launched at $(date +'%T') #\n" >> $LOGRSYNC
printf "###############################\n" >> $LOGRSYNC
printf "\n" >> $LOGRSYNC

printf "stopping looper ..." >> $LOGRSYNC
sudo /etc/init.d/videoloop stop >> $LOGRSYNC && printf " ...done\n\n" >> $LOGRSYNC

printf "synchronizing tmp-videos with videos folder:\n" >> $LOGRSYNC
rsync -avzh --delete /home/pi/tmp-videos/ /home/pi/videos >> $LOGRSYNC && printf "\ndone.\n\n" >> $LOGRSYNC

printf "\nstarting looper..." >> $LOGRSYNC
sudo /etc/init.d/videoloop start >> $LOGRSYNC && printf " ...done\n\n" >> $LOGRSYNC

