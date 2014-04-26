#! /bin/bash 

# Copyright (c) 2013, Giovanni Dante Grazioli (deroad)

# ================================================ OPTIONS =====================================================
# Streaming Options
OUTRES="1280x720"     # Twitch Output Resolution
FPS="24"              # Frame per Seconds (Suggested 24, 25, 30 or 60)
THREADS="4"           # Change this if you have a good CPU (Suggested 4 threads, Max 6 threads)
QUALITY="ultrafast"   # ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
CBR="1000k"           # Constant bitrate (CBR) Increase this to get a better pixel quality (1000k - 3000k for twitch)

# Webcam Options
WEBCAM="/dev/video1" # WebCam device
WEBCAM_WH="320:240"  # WebCam Width end Height

# STREAM KEY
# You can find YOUR key here: http://www.twitch.tv/broadcast/ (Show Key button)
# Save your key inside the twitch_key file
# Or make a global file named ".twitch_key" in your home directory (~/.twitch_key)

# Twitch Server list http://bashtech.net/twitch/ingest.php
SERVER="live-fra"    # EU server

# Change this to 'true' if you want to go always on FULLSCREEN, this will disable the output.
ALWAYS_FULLSCREEN=false

# Change this to 'true' if you want to hide your STREAM_KEY, for security purpose (this will disable most of the output).
# This will not affect the ALWAYS_FULLSCREEN option. ALWAYS_FULLSCREEN will always disable the output.
SUPPRESS_OUTPUT=false

# Twitch says it MUST have a 44100 rate, please do not change it unless you know what you are doing.
AUDIO_RATE="44100"

# ============================================== END OPTIONS ===================================================
# The following values are changed automatically, so do not change them
TOPXY="0,0"          # Position of the Window (You don't need to change this)
INRES="0x0"          # Game Resolution (You don't need to change this)
LOGLEVEL_ARG=""      # LogLevel, for security purpose (You don't need to change this) 

# ================================================= CHECKS =====================================================
# To see the output.
ECHO_LOG=""

# checks to avoid a false "true" where it checks for the webcam
if [ -z "$WEBCAM" ]; then
	ECHO_LOG=$ECHO_LOG"\nYour Webcam has been disabled because there isn't a WEBCAM in the options"
	WEBCAM="/dev/no-webcam"
else 
# checks to avoid a fail on loading the Webcam
	if [ -z "$WEBCAM_WH" ]; then
		ECHO_LOG=$ECHO_LOG"\nYour Webcam has been disabled because there isn't a WEBCAM_WH in the options"
		WEBCAM="/dev/no-webcam"
	fi
fi

# Find stream key
if [ -f ~/.twitch_key ]; then
    ECHO_LOG=$ECHO_LOG"\nUsing global twitch key located in home directory"
    STREAM_KEY=$(cat ~/.twitch_key)
else
    if [ -f ./twitch_key ]; then
        ECHO_LOG=$ECHO_LOG"\nUsing twitch key located in current running directory"
        STREAM_KEY=$(cat ./twitch_key)
    else
        echo "Could not locate ~/.twitch_key or twitch_key"
        exit 1
    fi
fi


# Find script name
SCRIPT_NAME=${0##*/}

# Suppress output for security purpose
if [ $SUPPRESS_OUTPUT = true ]; then
	ECHO_LOG=$ECHO_LOG"\nOutput blocked!"
	LOGLEVEL_ARG="-loglevel 0"
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
if [ -z "$ALWAYS_FULLSCREEN" ]; then
     ALWAYS_FULLSCREEN=false
fi
if [ -z "$AUDIO_RATE" ]; then
     AUDIO_RATE="44100"
fi
if [ -z "$LOGLEVEL_ARG" ]; then
     LOGLEVEL_ARG=""
fi
if [ -z "$SUPPRESS_OUTPUT" ]; then
     SUPPRESS_OUTPUT=false
fi
if [ -z "$STREAM_KEY" ]; then
     ECHO_LOG=$ECHO_LOG"\nSTREAM_KEY not set or there is a problem with it... Aborting."
     ECHO_LOG=$ECHO_LOG"\nCheck if the path to the file or the streaming key is correctly set."
     exit 1
fi

# ================================================= CODE =======================================================
# DO NOT CHANGE THE CODE!
MODULE_LOAD1=""
MODULE_LOAD2=""
APP_RETURN=""

showUsage(){
		echo "usage:"
		echo "      "$SCRIPT_NAME" [options]"
		echo "      -h          | show usage screen"
		echo "      -fullscreen | enable the fullscreen"
		echo "                    and disable the output"
		echo "      -window     | enable the window mode"
}

streamWebcam(){
        echo "Webcam found!!"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        echo " "
        avconv -f x11grab -s $INRES -framerate "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film  -acodec libmp3lame -threads $THREADS -vf "movie=$WEBCAM:f=video4linux2, scale=$WEBCAM_WH , setpts=PTS-STARTPTS [WebCam]; [in] setpts=PTS-STARTPTS, [WebCam] overlay=main_w-overlay_w-10:10 [out]" -strict normal -bufsize $CBR $LOGLEVEL_ARG "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
        APP_RETURN=$?
}

streamNoWebcam(){
        echo "Webcam NOT found!! ("$WEBCAM")"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        echo " "
        avconv -f x11grab -s $INRES -framerate "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal -bufsize $CBR $LOGLEVEL_ARG "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
        APP_RETURN=$?
}

loadModule(){
	MODULE_LOAD1=$(pactl load-module module-null-sink sink_name=GameAudio) # For Game Audio
	MODULE_LOAD2=$(pactl load-module module-null-sink sink_name=MicAudio ) # For Mic Audio
	pactl load-module module-device-manager >> /dev/null  
	pactl load-module module-loopback sink=GameAudio >> /dev/null      
	pactl load-module module-loopback sink=MicAudio >> /dev/null
}

unloadModule(){
	echo "Stopping Audio (Don't worry if you see errors here)"
	pactl unload-module $MODULE_LOAD1
	pactl unload-module $MODULE_LOAD2
	pactl unload-module module-device-manager
	pactl unload-module module-null-sink
	pactl unload-module module-loopback
	echo "Exit!"
}

echo " "
echo "Twitch Streamer for Linux ("$SCRIPT_NAME")"
echo "Copyright (c) 2013 - 2014, Giovanni Dante Grazioli (deroad)"
# To be sure to unload everything
trap "unloadModule; exit" SIGHUP SIGINT SIGTERM
echo -e $ECHO_LOG

if [ $# -eq 1 ]; then
    if [ $1 == "-h" ]; then
		showUsage
		exit 1
	elif [ $1 == "-fullscreen" ]; then
		echo "Going to fullscreen!"
		echo "Output blocked!"
		TOPXY="0,0"
		INRES=$(xwininfo -root | awk '/geometry/ {print $2}'i | sed -e 's/\+[0-9]//g')
		LOGLEVEL_ARG="-loglevel 0"
		SUPPRESS_OUTPUT=true
	elif [ $1 == "-window" ]; then
		echo "Click, with the mouse, on the Window that you want to Stream"
		rm -f twitch_tmp 2> /dev/null
		xwininfo -stats >> twitch_tmp
		TOPXY=$(cat twitch_tmp | awk 'FNR == 8 {print $4}')","$(cat twitch_tmp | awk 'FNR == 9 {print $4}')
		INRES=$(cat twitch_tmp | awk 'FNR == 12 {print $2}')"x"$(cat twitch_tmp | awk 'FNR == 13 {print $2}')
		rm -f twitch_tmp 2> /dev/null
		echo " "
	else
		echo "Unknown param:" $1
		showUsage
		exit 1
	fi
elif [ $# -eq 0 ]; then
	if [ $ALWAYS_FULLSCREEN = true ]; then
		echo "ALWAYS_FULLSCREEN is ON. Going to fullscreen!"
		echo "Output blocked!"
		TOPXY="0,0"
		INRES=$(xwininfo -root | awk '/geometry/ {print $2}'i | sed -e 's/\+[0-9]//g')
		LOGLEVEL_ARG="-loglevel 0"
		SUPPRESS_OUTPUT=true
	else
		echo "Click, with the mouse, on the Window that you want to Stream"
		rm -f twitch_tmp 2> /dev/null
		xwininfo -stats >> twitch_tmp
		TOPXY=$(cat twitch_tmp | awk 'FNR == 8 {print $4}')","$(cat twitch_tmp | awk 'FNR == 9 {print $4}')
		INRES=$(cat twitch_tmp | awk 'FNR == 12 {print $2}')"x"$(cat twitch_tmp | awk 'FNR == 13 {print $2}')
		rm -f twitch_tmp 2> /dev/null
		echo " "
	fi
else
	echo "There are some unknown params, please check what you wrote!"
	echo "Params: " $@
	showUsage
	exit 1
fi

# Setup
echo "Please setup the Audio Output to sink null (something like 'pavucontrol')"
# if you see errors here, please report on github
loadModule

# Disable trap
trap - SIGHUP SIGINT SIGTERM
# Checks if the webcam is loaded
if [ -c $WEBCAM ]; then
     streamWebcam
else
     streamNoWebcam
fi

# Checks if any error returned
if [ $APP_RETURN -eq 1 ]; then
	if [ $SUPPRESS_OUTPUT = true ]; then
		echo "Something went wrong. check the log without FULLSCREEN or SUPPRESS_OUTPUT"
	fi
fi
echo " "

# Closing..
unloadModule

