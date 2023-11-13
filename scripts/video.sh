#!/bin/bash

Devices=$(adb devices  | grep -sw device | wc -l)
if [[ $Devices -lt "2" ]]
then
S=$(adb devices  | grep -sw device | cut -d "d" -f 1| tr -d '[:space:]')
export ANDROID_SERIAL=$S
else
adb devices
echo "Enter SN of device"
read A
export ANDROID_SERIAL=$A
fi

adb reboot
adb wait-for-device

Loaded=$(adb shell getprop sys.boot_completed | tr -d '\r')

while [ "$Loaded" != "1" ]; 
do
        sleep 2
        Loaded=$(adb shell getprop sys.boot_completed | tr -d '\r')
done
sleep 5

################################################################################################################################

videoFilePath=$(cat testconfig | grep -i "VIDEO file path" | cut -d "|" -f 2)
videoFileName=$(cat testconfig | grep -i "VIDEO file name" | cut -d "|" -f 2)
adb push $videoFilePath$videoFileName /sdcard/Movies


if [[ $? -ne "0"  ]]
then
  echo "Error file is not pushed! TEST FAILED!"
  exit 1
else

	adb shell am start -a android.intent.action.VIEW -d file:///sdcard/Movies/$videoFileName -t video/*
sleep 3
  adb shell dumpsys media.player > duringPlaying
  Started=$(grep -i "state(5)"  duringPlaying | wc -l) #state 5 - playing
	if [[ $Started -eq "0" ]]
	then
	echo "Error Video File cant START TEST FAILED!"
        exit 2
	fi

sleep 15
  adb shell input keyevent 85  #Pause Button
sleep 4
  adb shell dumpsys media.player > forceStopped
  Stopped=$(grep -i "state(6)" forceStopped | wc -l) #state 6 - paused
	if [[ $Stopped -eq "0" ]]
	then
	echo "Error Audio File cant STOP TEST FAILED!"
        exit 3
	fi
#adb shell am force-stop android.intent.action.VIEW
adb shell "input keyevent 3"

rm duringPlaying
rm forceStopped
echo "VIDEO TEST PASSED!"
fi
