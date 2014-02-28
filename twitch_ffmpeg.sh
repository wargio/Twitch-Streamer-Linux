#! /bin/bash 

# Copyright (c) 2013, Giovanni Dante Grazioli (deroad)

# ================================================ OPTIONS =====================================================
# Streaming Options
OUTRES="1280x720"    # Twitch Output Resolution
FPS="30"             # Frame per Seconds (Suggested 24, 25, 30 or 60)
THREADS="4"          # Change this if you have a good CPU (Suggested 4 threads, Max 6 threads)
QUALITY="medium"     # ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
CBR="1000k"          # Constant bitrate (CBR) Increase this to get a better pixel quality (1000k - 2000k for twitch)

# Webcam Options
WEBCAM="/dev/video1" # WebCam device
WEBCAM_WH="320:240"  # WebCam Width end Height

# STREAM KEY
# You can find YOUR key here: http://www.twitch.tv/broadcast/ (Show Key button)
# Save your key inside the twitch_key file
# Or make a global file named ".twitch_key" in your home directory (~/.twitch_key)

# Twitch Server list http://bashtech.net/twitch/ingest.php
SERVER="live-fra"    # EU server

# ============================================== END OPTIONS ===================================================
# The following values are changed automatically, so do not change them
TOPXY="0,0"          # Position of the Window (You don't need to change this)
INRES="0x0"          # Game Resolution (You don't need to change this)
STREAM_KEY=""
FULLSCREEN=false

# ================================================= CHECKS =====================================================
# checks to avoid a false "true" where it checks for the webcam
if [ -z "$WEBCAM" ]; then
	echo "Your Webcam has been disabled because there isn't a WEBCAM in the options"
	WEBCAM="/dev/no-webcam"
else 
# checks to avoid a fail on loading the Webcam
	if [ -z "$WEBCAM_WH" ]; then
		echo "Your Webcam has been disabled because there isn't a WEBCAM_WH in the options"
		WEBCAM="/dev/no-webcam"
	fi
fi

# Find stream key
if [ -f ./twitch_key ]; then
    echo "Using twitch key located in current running directory"
    STREAM_KEY=$(cat ./twitch_key)
else
    if [ -f ~/.twitch_key ]; then
        echo "Using global twitch key located in home directory"
        STREAM_KEY=$(cat ~/.twitch_key)
    fi
fi

# checks to avoid fails
if [ -z "$SERVER" ]; then
     SERVER="live"
fi
if [ -z "$OUTRES" ]; then
     OUTRES="1280x720"
fi
if [ -z "$FPS" ]; then
     FPS="30"
     GOP="60"
     GOPMIN="30"
else
     GOP=$(($FPS*2))
     GOPMIN=$FPS
fi
if [ -z "$THREADS" ]; then
     THREADS="4"
fi
if [ -z "$QUALITY" ]; then
     QUALITY="fast"
fi
if [ -z "$CBR" ]; then
     CBR="1000k"
fi
if [ -z "$STREAM_KEY" ]; then
     echo "STREAM_KEY not set or there is a problem with it... Aborting."
     echo "Check if the path to the file or the streaming key is correctly set."
     exit 1
fi

read -p "Do you wish to go fullscreen (alternative is select single window) [yY]? " yn
if [[ $yn == [yY] ]];  then
    FULLSCREEN=true;
fi

# ================================================= CODE =======================================================
# DO NOT CHANGE THE CODE!

streamWebcam(){
        echo "Webcam found!!"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        ffmpeg -f x11grab -s $INRES -r "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar 44100 -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film  -acodec libmp3lame -threads $THREADS -vf "movie=$WEBCAM:f=video4linux2, scale=$WEBCAM_WH , setpts=PTS-STARTPTS [WebCam]; [in] setpts=PTS-STARTPTS, [WebCam] overlay=main_w-overlay_w-10:10 [out]" -strict normal -bufsize $CBR  "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
}

streamNoWebcam(){
        echo "Webcam NOT found!! ("$WEBCAM")"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        ffmpeg -f x11grab -s $INRES -r "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar 44100 -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal -bufsize $CBR "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
}


echo "Twitch Streamer for Linux"
echo "Copyright (c) 2013, Giovanni Dante Grazioli (deroad)"
echo " "

# Get Game Window
if [ $FULLSCREEN = true ]; then
    INRES=$(xwininfo -root | awk '/geometry/ {print $2}'i | sed -e 's/\+[0-9]//g')
else
    echo "Click, with the mouse, on the Window that you want to Stream"
    rm -f twitch_tmp 2> /dev/null
    xwininfo -stats >> twitch_tmp
    TOPXY=$(cat twitch_tmp | awk 'FNR == 8 {print $4}')","$(cat twitch_tmp | awk 'FNR == 9 {print $4}')
    INRES=$(cat twitch_tmp | awk 'FNR == 12 {print $2}')"x"$(cat twitch_tmp | awk 'FNR == 13 {print $2}')
    rm -f twitch_tmp 2> /dev/null
    echo " "
fi

# Setup
echo "Please setup the Audio Output to sink null (something like 'pavucontrol')"
# if you see errors here, please report on github
MODULE_LOAD1=$(pactl load-module module-null-sink sink_name=GameAudio) # For Game Audio
MODULE_LOAD2=$(pactl load-module module-null-sink sink_name=MicAudio ) # For Mic Audio
pactl load-module module-device-manager >> /dev/null  
pactl load-module module-loopback sink=GameAudio >> /dev/null      
pactl load-module module-loopback sink=MicAudio >> /dev/null
echo " "

# Checks if the webcam is loaded
if [ -c $WEBCAM ]; then
     streamWebcam
else
     streamNoWebcam
fi
echo " "

# Closing..
echo "Stopping Audio (Don't worry if you see errors here)"
pactl unload-module $MODULE_LOAD1
pactl unload-module $MODULE_LOAD2
pactl unload-module module-device-manager
pactl unload-module module-null-sink
pactl unload-module module-loopback
echo "Exit!"

