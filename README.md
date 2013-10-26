Twitch Streamer For Linux
=========================

This is a script dedicated to stream to Twitch.tv. it also has Webcam support!

Tested on:
* Linux:    Ubuntu 13.04
* CPU:      AMD Athlon(tm) 64 X2 Dual Core Processor 4200+ × 2
* Ram:      2 GB
* Arch:     64bit
* GPU:      Radeon X1300 PCI (ATI RV515)
* Bandwith: ~70 byte/s
* Mem Used: ~192 MB (2 Threads)

![Streaming Quality](https://raw.github.com/wargio/Twitch-Streamer-Linux/master/Screenshots/Streaming-Quality.png)

Authors:
--------

* Giovanni Dante Grazioli

How to
------

* Go to http://www.twitch.tv/broadcast/ , click on the **Show Key** button and copy and paste the key inside the twitch_key file
* To save the Streaming, go to http://twitch.tv/settings/videos and check **Archive Broadcasts - Automatically archive my broadcasts**
* Open now the twitch.sh and edit the settings

        Value      Example                  Description                       
        ---------- ------------------------ ---------------------------------------------------------------------------------------------------------
        OUTRES     "1280x720"               Twitch Output Resolution ("1920x1080" should be the maximum resolution)
        FPS        "60"                     Frame per Seconds (Suggested 30 or 60)
        THREADS    "2"                      Change this if you have a good CPU (Suggested 4 threads, Max 6 threads)
        QUALITY    "medium" or "slow"       Streaming Quality (ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo)
        WEBCAM     "/dev/video1"            WebCam chardevice under /dev
        WEBCAM_WH  "320:240"                WebCam Width end Height in the Output
        STREAM_KEY "live_xxxxxxxx_yyyyyy.." Your Twitch key (inside the script it takes the key from twitch_key file)
        SERVER     "live" or "live-fra"     Twitch Server list at http://bashtech.net/twitch/ingest.php

* Open the game that you want to stream and set window mode.
* Open a terminal and run the script

        $ ./twitch.sh

* Click with your Mouse on the game window
* Now you should be live (check on your channel).
* You can set the Audio settings (select the Null Output on pavucontrol)
* To stop the stream, click on the terminal and press CTRL+C

Dependencies:
-------------

        avconv pulseaudio alsa xwininfo pactl ffmpeg libavcodec-extra-53

###Suggested:

        pavucontrol

Screenshot:
-----------

![Screenshot from twitch.tv](https://raw.github.com/wargio/Twitch-Streamer-Linux/master/Screenshots/Screenshot.png)
