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

###Contributors

* İlteriş Eroğlu (linuxgemini)
* yofreke
* Vilsol

How to
------

* Go to http://www.twitch.tv/broadcast/ , click on the **Show Key** button and copy and paste the key inside the twitch_key file or inside the ~/.twitch_key
* To save the Streaming, go to http://twitch.tv/settings/videos and check **Archive Broadcasts - Automatically archive my broadcasts**
* Open now the twitch.sh and edit the settings

        Value              Example                  Description                       
        ------------------ ------------------------ ---------------------------------------------------------------------------------------------------------
        OUTRES             "1280x720"               Twitch Output Resolution ("1920x1080" should be the maximum resolution)
        FPS                "24"                     Frame per Seconds (Suggested 24, 25, 30 or 60)
        THREADS            "4"                      Change this if you have a good CPU (Suggested 4 threads, Max 6 threads)
        QUALITY            "medium" or "veryfast"   Streaming Quality (ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow, placebo)
        WEBCAM             "/dev/video1"            WebCam chardevice under /dev
        WEBCAM_WH          "320:240"                WebCam Width end Height in the Output
        WEBCAM_XY          "10:10"                  WebCam Position if empty then it will set the standard position
        SERVER             "live" or "live-fra"     Twitch Server list at http://bashtech.net/twitch/ingest.php
        CBR                "1000k" to "3000k"       Constant bitrate. Increase this to get a better pixel quality (Twitch suggest between 1000k to 3000k)
        ALWAYS_FULLSCREEN  "false" or "true"        Change this to 'true' if you want to go always on FULLSCREEN, this will disable the output.
        SUPPRESS_OUTPUT    "false" or "true"        Change this to 'true' if you want to hide your STREAM_KEY, for security purpose. This will not affect 
                                                    the ALWAYS_FULLSCREEN option. ALWAYS_FULLSCREEN will always disable the output.
        AUDIO_RATE         "44100"                  Twitch Audio Rate. Twitch itself, says must be 2 channels with 44100 as rate; so DO NOT CHANGE IT!
        FILE_VIDEO         "My_stream.flv"          File name to redirect the stream if there's the -save arg (go to the How To to see how it works)

* Open the game that you want to stream and set window mode.
* Open a terminal, browse to the twitch script directory and run the script

        $ ./twitch_avconv.sh 

* If the avconv script gives you an error, use FFMPEG version. works exactly the same.

        $ ./twitch_ffmpeg.sh 

* Click with your Mouse on the game window
* Now you should be live (check on your channel).
* You can set the Audio settings (select the Null Output on pavucontrol)
* To stop the stream, click on the terminal and press CTRL+C
* **BE CAREFUL ON SHOWING THE TERMINAL SINCE AVCONV/FFMPEG PRINTS ON THE TERMINAL THE KEY**
* For suggestion or bugfix, please write to me on github. (I love suggestions! <3 )
* Please do NOT write for support on my BLOG. post bug reports on http://github.com/wargio/Twitch-Streamer-Linux !

Additional How to
-----------------

* You can run the scripts with some arguments (you can use a combination of these):

        Value              Description                       
        ------------------ ----------------------------------------------------------------------------
         -h                Display the usage screen
         -fullscreen       Run the script in FULLSCREEN mode 
         -window           Run the script in WINDOW mode
         -save             Save the video to the file FILE_VIDEO instead of streaming it
	 -quiet            Disables most of the outputs (The Twitch KEY will be hided)


Setup Audio (with pavucontrol):
-------------------------------
* My microphone is `Turtle Beach PLa Headset` and my game is `Syobon Action (Cat Mario)`
* Open the game you want to stream and exec the script
* Now open `pavucontrol`
* Under `Playback`:
![Screenshot from pavucontrol](https://raw.github.com/wargio/Twitch-Streamer-Linux/master/Screenshots/Twitch_Audio00.png)
* Under `Recording`:
![Screenshot from pavucontrol](https://raw.github.com/wargio/Twitch-Streamer-Linux/master/Screenshots/Twitch_Audio01.png)
* Done (For `ffmpeg/avconv` setting,  `Monitor of MicAudio` or `Monitor of GameAudio`. it's the same).
* If you don't see any `Monitor of MicAudio` or `Monitor of GameAudio`, but only `Monitor of null output`, use it, don't worry.

Dependencies:
-------------
These dependencies are not the name of the packages that you need. They are the name of the executables/libs that you need.

        avconv pulseaudio alsa xwininfo pactl ffmpeg libavcodec-extra-53

###Suggested:

        pavucontrol

FAQ
---
* How do i choose the bitrate?

	The optimal bitrate can be calculated in this way: `bitrate = Width*Height/144`, 
	an example `720*480/144 = 2400 (k)` but if you get a bitrate above 5000(k)
	like `1920*1080/144=2073456(k = ~2073 M)` choose 5000k, because 6000k is
	DVD quality. 

* I see some errors after `Stopping Audio (Don't worry if you see errors here)`, should i worry about this?

	No, you don't. They are supposed to show up.

* Which is the Webcam standard position on the screen?

	The standard position is: (ScreenWidth - WebcamWidth - 10):10 (Upper Right corner)
	Keep in mind that the coordinates start from 0:0 (Upper Left corner) to Width:Height (Bottom Right corner)

* How i can test the output before going to livestream?

	Use the `-save` arg for the script: `./twitch_ffmpeg -save` or `./twitch_avconv -save`
	in this way you can see how it looks like and change things if they are not ok.

* How i can save the output instead of livestreaming?
	Use the `-save` arg for the script: `./twitch_ffmpeg -save` or `./twitch_avconv -save`


Screenshot:
-----------

![Screenshot from twitch.tv](https://raw.github.com/wargio/Twitch-Streamer-Linux/master/Screenshots/Screenshot.png)


