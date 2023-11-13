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


##########################################################
adb root
sleep 2
audioFilePath=$(cat ~/bin/testconfig | grep -i "AUDIO file path" | cut -d "|" -f 2)
audioFileName=$(cat ~/bin/testconfig | grep -i "AUDIO file name" | cut -d "|" -f 2)
adb push $audioFilePath$audioFileName /sdcard/Music

if [[ $? -ne "0"  ]]
then
  echo "Error file is not pushed! TEST FAILED!"
  exit 1
else

##########################################################
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

adb shell am start -n com.android.music/com.android.music.MediaPlaybackActivity -d file:///sdcard/Music/$audioFileName
sleep 3
  adb shell dumpsys audio > duringPlaying
  Started=$(grep -i "state:started" duringPlaying | wc -l)
	if [[ $Started -eq "0" ]]
	then
	echo "Error Audio File cant START TEST FAILED!"
        exit 2
	fi
sleep 3
	adb shell "input keyevent 24" #vol + button
sleep 1
	adb shell "input keyevent 24" #vol + button
		if [[ $? -ne "0" ]]
		then
		echo "Error Vol + Function dont work TEST FAILED!"
		exit 3
		fi
sleep 2
	adb shell "input keyevent 25" #vol - button
sleep 1
	adb shell "input keyevent 25" #vol - button
 		if [[ $? -ne "0" ]]
		then
		echo "Error Vol - Function dont work TEST FAILED!"
		exit 4
		fi
 
sleep 10
adb shell input keyevent 127 #Pause Button in music player
sleep 5
adb shell input keyevent 86  #Stop Button
sleep 5
  adb shell dumpsys audio > forceStopped
  Stopped=$(grep -i "state:paused " forceStopped | wc -l)
	if [[ $Stopped -eq "0" ]]
	then
	echo "Error Audio File cant STOP TEST FAILED!"
        exit 5
	fi

  adb shell "am force-stop com.android.music"
  adb shell "input keyevent 3"	
fi

rm forceStopped
rm duringPlaying

echo "AUDIO TEST PASSED!"  
