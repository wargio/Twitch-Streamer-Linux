#! /bin/bash 

# Copyright (c) 2013, Giovanni Dante Grazioli (deroad)

# ================================================ OPTIONS =====================================================
# Streaming Options
OUTRES="1280x720"    # Twitch Output Resolution
FPS="60"             # Frame per Seconds (Suggested 30 or 60)
THREADS="2"          # Change this if you have a good CPU (Suggested 4 threads, Max 6 threads)
QUALITY="medium"     # ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo

# Webcam Options
WEBCAM="/dev/video1" # WebCam device
WEBCAM_WH="320:240"  # WebCam Width end Height

# You can find YOUR key here: http://www.twitch.tv/broadcast/ (Show Key button)
# Save your key inside the twitch_key file
STREAM_KEY=$(cat twitch_key)

# Twitch Server list http://bashtech.net/twitch/ingest.php
SERVER="live-fra"    # EU server

# ============================================== END OPTIONS ===================================================
# The following values are changed automatically, so do not change them
TOPXY="0,0"          # Position of the Window (You don't need to change this)
INRES="0x0"          # Game Resolution (You don't need to change this)
CBR="400k"           # Constant bitrate (CBR) 

# ================================================= CODE =======================================================
# DO NOT CHANGE THE CODE!

streamWebcam(){
        echo "Webcam found!!"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        avconv -f x11grab -s $INRES  -r "$FPS" -i :0.0+$TOPXY  -f alsa -ac 2 -i pulse -vcodec libx264 -s $OUTRES -preset $QUALITY -acodec libmp3lame -ar 44100 -threads $THREADS -qscale 3 -b 712000 -bufsize 512k -vf "movie=$WEBCAM:f=video4linux2, scale=$WEBCAM_WH , setpts=PTS-STARTPTS [WebCam]; [in] setpts=PTS-STARTPTS, [WebCam] overlay=main_w-overlay_w-10:10 [out]" -force_key_frames 2 -b $CBR -minrate $CBR -maxrate $CBR -g 2 -keyint_min 2  -f flv "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
}

streamNoWebcam(){
        echo "Webcam NOT found!! ("$WEBCAM")"
        echo "You should be online! Check on http://twitch.tv/ (Press CTRL+C to stop)"
        avconv -f x11grab -s $INRES -r "$FPS" -i :0.0+$TOPXY  -f alsa -ac 2 -i pulse -vcodec libx264 -s $OUTRES -preset $QUALITY -acodec libmp3lame -ar 44100 -threads $THREADS -qscale 3 -b 712000 -bufsize 512k -force_key_frames 2 -b $CBR -minrate $CBR -maxrate $CBR -g 2 -keyint_min 2 -f flv "rtmp://$SERVER.twitch.tv/app/$STREAM_KEY"
}


echo "Twitch Streamer for Linux"
echo " "
echo "Copyright (c) 2013, Giovanni Dante Grazioli (deroad)"
echo " "
echo " "

# Get Game Window
echo "Click, with the mouse, on the Window that you want to Stream"
rm -f twitch_tmp 2> /dev/null
xwininfo -stats >> twitch_tmp
TOPXY=$(cat twitch_tmp | awk 'FNR == 8 {print $4}')","$(cat twitch_tmp | awk 'FNR == 9 {print $4}')
INRES=$(cat twitch_tmp | awk 'FNR == 12 {print $2}')"x"$(cat twitch_tmp | awk 'FNR == 13 {print $2}')
rm -f twitch_tmp 2> /dev/null
echo " "

# Setup
echo "Please setup the Audio Output (something like 'pavucontrol')"
# if you see errors here, please report on github
MODULE_LOAD1=$(pactl load-module module-null-sink sink_name=GameAudio) # For Game Audio
MODULE_LOAD1=$(pactl load-module module-null-sink sink_name=MicAudio ) # For Mic Audio
pactl load-module module-loopback sink=GameAudio       
pactl load-module module-loopback sink=MicAudio
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
pactl unload-module module-null-sink
pactl unload-module module-loopback
echo "Exit!"
