#! /bin/bash 

# Copyright (c) 2013-2014, Giovanni Dante Grazioli (deroad)

# ================================================ OPTIONS =====================================================
# Add the FFMPEG ABSOLUTE PATH "/path/to/ffmpeg"
FFMPEG_PATH="ffmpeg"

# Streaming Options
OUTRES="1280x720"     # Twitch Output Resolution
FPS="24"              # Frame per Seconds (Suggested 24, 25, 30 or 60)
THREADS="4"           # Change this if you have a good CPU (Suggested 4 threads, Max 6 threads)
QUALITY="ultrafast"   # ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo
CBR="1000k"           # Constant bitrate (CBR) Increase this to get a better pixel quality (1000k - 3000k for twitch)

# Webcam Options
WEBCAM="/dev/video1" # WebCam device
WEBCAM_WH="320:240"  # WebCam Width end Height
WEBCAM_XY=""         # WebCam Position (in pixel) example: "10:10", if "" (empty) then it will set the standard position

# File to save if you do not want to stream
FILE_VIDEO="my.flv"  # File name

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
SCREEN_SETUP=0       # Do not change this. it's used for the args.
STREAM_SAVE=0        # Do not change this. it's used for the args.
# ================================================= CHECKS =====================================================
# To see the output.
ECHO_LOG=""

# checks to avoid a false "true" where it checks for the webcam
if [ -z "$WEBCAM" ]; then
	ECHO_LOG=$ECHO_LOG"\nYour Webcam has been disabled because there isn't a WEBCAM in the options"
	WEBCAM="/dev/no-webcam"
elif [ -z "$WEBCAM_WH" ]; then
# checks to avoid a fail on loading the Webcam
	ECHO_LOG=$ECHO_LOG"\nYour Webcam has been disabled because there isn't a WEBCAM_WH in the options"
	WEBCAM="/dev/no-webcam"
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
if [ -z "$FILE_VIDEO" ]; then
     FILE_VIDEO="video.flv"
fi
if [ ! $SCREEN_SETUP -eq 0 ]; then
     SCREEN_SETUP=0
fi
if [ ! $STREAM_SAVE -eq 0 ]; then
     STREAM_SAVE=0
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

checkFileExists(){
	if [ -f $FILE_VIDEO ]; then
	     i=0
	     TMP="OLD_"$i"_"$FILE_VIDEO
	     echo "$FILE_VIDEO already exists! finding a new name for the old file"
	     while [ -f $TMP ]
	     do
	     	i=$((i+1))
	     	TMP="OLD_"$i"_"$FILE_VIDEO
		echo "$TMP already exists"
	     done
	     echo "The old stream $FILE_VIDEO has been renamed as $TMP"
	     echo "The new stream will be saved into $FILE_VIDEO"
	     mv $FILE_VIDEO $TMP
	fi
}

streamWebcam(){
        echo "Webcam found!!"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        echo " "
        if [ -z "$WEBCAM_XY" ]; then
                # checks to avoid a fail on loading the Webcam
                #standard position is: main_w - overlay_w - 10:10
                WEBCAM_XY="$(($(echo $INRES | awk -F"x" '{ print $1 }') - $(echo $WEBCAM_WH | awk -F":" '{ print $1 }') - 10)):10"
                echo "There isn't a WEBCAM_XY in the options, i'll generate the standard one ($WEBCAM_XY)"
        fi
        $FFMPEG_PATH -f x11grab -s $INRES -framerate "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film  -acodec libmp3lame -threads $THREADS -vf "movie=$WEBCAM:f=video4linux2, scale=$WEBCAM_WH , setpts=PTS-STARTPTS [WebCam]; [in] setpts=PTS-STARTPTS [Screen]; [Screen][WebCam] overlay=$WEBCAM_XY [out]" -strict normal -bufsize $CBR $LOGLEVEL_ARG "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
        APP_RETURN=$?
}

streamNoWebcam(){
        echo "Webcam NOT found!! ("$WEBCAM")"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        echo " "
        $FFMPEG_PATH -f x11grab -s $INRES -framerate "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN  -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal -bufsize $CBR $LOGLEVEL_ARG "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
        APP_RETURN=$?
}

saveStreamWebcam(){
        echo "Webcam found!!"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        echo " "
        if [ -z "$WEBCAM_XY" ]; then
                # checks to avoid a fail on loading the Webcam
                #standard position is: main_w - overlay_w - 10:10
                WEBCAM_XY="$(($(echo $INRES | awk -F"x" '{ print $1 }') - $(echo $WEBCAM_WH | awk -F":" '{ print $1 }') - 10)):10"
                echo "There isn't a WEBCAM_XY in the options, i'll generate the standard one ($WEBCAM_XY)"
        fi
        $FFMPEG_PATH -f x11grab -s $INRES -framerate "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN -b $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film  -acodec libmp3lame -threads $THREADS -vf "movie=$WEBCAM:f=video4linux2, scale=$WEBCAM_WH , setpts=PTS-STARTPTS [WebCam]; [in] setpts=PTS-STARTPTS [Screen]; [Screen][WebCam] overlay=$WEBCAM_XY [out]" -strict normal -bufsize $CBR $LOGLEVEL_ARG $FILE_VIDEO
        APP_RETURN=$?
}

saveStreamNoWebcam(){
        echo "Webcam NOT found!! ("$WEBCAM")"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        echo " "
        $FFMPEG_PATH -f x11grab -s $INRES -framerate "$FPS" -i :0.0+$TOPXY -f alsa -i pulse -f flv -ac 2 -ar $AUDIO_RATE -vcodec libx264 -g $GOP -keyint_min $GOPMIN  -b:v $CBR -minrate $CBR -maxrate $CBR -pix_fmt yuv420p -s $OUTRES -preset $QUALITY -tune film -acodec libmp3lame -threads $THREADS -strict normal -bufsize $CBR $LOGLEVEL_ARG $FILE_VIDEO
        APP_RETURN=$?
}

doDefaults(){
	if [ $ALWAYS_FULLSCREEN = true ]; then
		echo "[+] ALWAYS_FULLSCREEN is ON. Going to fullscreen!"
		echo "[+] Output blocked!"
		TOPXY="0,0"
		INRES=$(xwininfo -root | awk '/geometry/ {print $2}'i | sed -e 's/\+[0-9]//g')
		LOGLEVEL_ARG="-loglevel 0"
		SUPPRESS_OUTPUT=true
	else
		echo "[+] Click, with the mouse, on the Window that you want to Stream"
		rm -f twitch_tmp 2> /dev/null
		xwininfo -stats >> twitch_tmp
		TOPXY=$(cat twitch_tmp | awk 'FNR == 8 {print $4}')","$(cat twitch_tmp | awk 'FNR == 9 {print $4}')
		INRES=$(cat twitch_tmp | awk 'FNR == 12 {print $2}')"x"$(cat twitch_tmp | awk 'FNR == 13 {print $2}')
		rm -f twitch_tmp 2> /dev/null
		echo " "
	fi
}

loadModule(){
	MODULE_LOAD1=$(pactl load-module module-null-sink sink_name=GameAudio sink_properties=device.description="GameAudio") # For Game Audio
	MODULE_LOAD2=$(pactl load-module module-null-sink sink_name=MicAudio sink_properties=device.description="MicAudio") # For Mic Audio
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

showUsage(){
		echo "usage:"
		echo "      "$SCRIPT_NAME" [options]"
		echo "      -h          | show usage screen"
		echo "      -fullscreen | enable the fullscreen"
		echo "                    and disable the output"
		echo "      -window     | enable the window mode"
		echo "      -save       | save the video to a file"
		echo "                    instead of streaming it"
		echo "      -quiet      | disables most of the outputs"
}


echo " "
echo "Twitch Streamer for Linux ("$SCRIPT_NAME")"
echo "Copyright (c) 2013 - 2014, Giovanni Dante Grazioli (deroad)"
# To be sure to unload everything
trap "unloadModule; exit" SIGHUP SIGINT SIGTERM
echo -e $ECHO_LOG

if [ $# -ge 1 ]; then
    for ARG in "$@"
    do
	if [ $ARG == "-h" ]; then
		showUsage
		exit 1
	elif [ $ARG == "-fullscreen" ]; then
		if [ ! $SCREEN_SETUP -eq 0 ]; then
		    continue
		fi
		echo "[+] Going to fullscreen! Output blocked!"
		TOPXY="0,0"
		INRES=$(xwininfo -root | awk '/geometry/ {print $2}'i | sed -e 's/\+[0-9]//g')
		LOGLEVEL_ARG="-loglevel 0"
		SUPPRESS_OUTPUT=true
		SCREEN_SETUP=1
	elif [ $ARG == "-window" ]; then
		if [ $SCREEN_SETUP -eq 1 ]; then
		     continue
		fi
		echo "[+] Click, with the mouse, on the Window that you want to Stream"
		rm -f twitch_tmp 2> /dev/null
		xwininfo -stats >> twitch_tmp
		TOPXY=$(cat twitch_tmp | awk 'FNR == 8 {print $4}')","$(cat twitch_tmp | awk 'FNR == 9 {print $4}')
		INRES=$(cat twitch_tmp | awk 'FNR == 12 {print $2}')"x"$(cat twitch_tmp | awk 'FNR == 13 {print $2}')
		rm -f twitch_tmp 2> /dev/null
		SCREEN_SETUP=2
	elif [ $ARG == "-save" ]; then
		if [ ! $STREAM_SAVE -eq 0 ]; then
		     continue
		fi
		echo "[+] Saving the video into $FILE_VIDEO instead of stream to Twitch.tv"
		STREAM_SAVE=1
	elif [ $ARG == "-quiet" ]; then
		if [ $SUPPRESS_OUTPUT = true ]; then
		     continue
		fi
		echo "[+] Quiet Mode"
		LOGLEVEL_ARG="-loglevel 0"
		SUPPRESS_OUTPUT=true
	else
		echo "[+] Unknown param:" $ARG
		showUsage
		exit 1
	fi
    done
elif [ $# -eq 0 ]; then
	doDefaults
	SCREEN_SETUP=1;
else
	# You should never get here.. but who knows..
	echo "[+] There are some unknown params, please check what you wrote!"
	echo "[+] Params: " $@
	showUsage
	exit 1
fi
echo " "
# Setup
echo "Please setup the Audio Output to sink null (something like 'pavucontrol')"
# if you see errors here, please report on github
loadModule

# Disable trap
trap - SIGHUP SIGINT SIGTERM
# Checks if the screen got a setup
if [ $SCREEN_SETUP -eq 0 ]; then
    # if not then, get the defaults
    doDefaults
fi
# Checks if the webcam is loaded
if [ $STREAM_SAVE -eq 1 ]; then
     checkFileExists
     if [ -c $WEBCAM ]; then
	saveStreamWebcam
     else
	saveStreamNoWebcam
     fi
else
     if [ -c $WEBCAM ]; then
	streamWebcam
     else
	streamNoWebcam
     fi
fi
# Checks if any error returned
if [ $APP_RETURN -eq 1 ]; then
	if [ $SUPPRESS_OUTPUT = true ]; then
		echo "[+] Something went wrong. check the log without FULLSCREEN or SUPPRESS_OUTPUT options"
	fi
fi
echo " "

# Closing..
unloadModule

