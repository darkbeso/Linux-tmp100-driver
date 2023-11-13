#!/bin/bash

v_file=$1

if [ -z "$wav_file" ]
then
    wav_file=test.wav
fi


./wait-for-ripley.sh
adb root >/dev/null
adb push "$wav_file" /sdcard >/dev/null

adb shell 'tinymix "HDMI Mixer MultiMedia1" 1'
adb shell 'tinymix "HDMI RX Format" LPCM'
adb shell 'tinymix "HDMI_RX Channels" Two'

adb shell "tinyplay /sdcard/'$wav_file' -T 7" >/dev/null

sleep 5

adb shell 'tinymix "HDMI Mixer MultiMedia1" 0'
