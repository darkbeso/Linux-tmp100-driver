#!/bin/bash

Devices=$(adb devices  | grep -sw device | wc -l)
if [[ $Devices -lt "2" ]]
then
S=$(adb devices  | grep -sw device | cut -d "d" -f 1| tr -d '[:space:]')
export ANDROID_SERIAL=$S
else
adb devices
echo "Enter SN of device"
read SN
export ANDROID_SERIAL=$SN
fi

adb shell "rm -rf /sdcard/DCIM/Camera/"

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

cameraName=$(cat testconfig | grep -i "CAMERA NAME" | cut -d "|" -f 2)
adb shell "am start $cameraName" #open camera

if [[ $? -ne "0"  ]]
  then
  echo "Error camera cannot open! TEST FAILED!"
  exit 1
fi
sleep 4

adb shell input tap 300 300 #focus the camera adb shell "input keyevent 80"

	if [[ $? -ne "0"  ]]
	then
  	echo "Error cant focus the camera! TEST FAILED!"
  	exit 2
	fi


adb shell uiautomator dump /sdcard/camerashot.xml ;adb pull /sdcard/camerashot.xml ; 

Line=$(cat camerashot.xml |  grep -o -P '.{0,3}shutter_button.{0,293}') #save the 33th elements - resource-id="org.codeaurora.snapcam:id/shutter_button"
sleep 2
cat camerashot.xml | grep -o -P '.{0,3}shutter_button.{0,293}' > TEMPPhoto #save bounds from camerashot.xml into TEMP fail
sleep 2
ShutterCoord=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /clickable="true"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./TEMPPhoto) #save coords in ShutterCoord

adb shell input tap $ShutterCoord #tap on Shutter Button take first photo to create DCIM/Camera folder
sleep 2
FirstPhotoCheck=$(adb shell "ls -la /sdcard/DCIM/Camera" | wc -l) #checking files inside camera folder 
sleep 2
adb shell input tap $ShutterCoord #take second photo for comparison
sleep 2
SecondPhotoCheck=$(adb shell "ls -la /sdcard/DCIM/Camera" | wc -l) #checking files inside camera folder 

	if [[ "$FirstPhotoCheck" -eq "$SecondPhotoCheck" ]]
	then
  	echo "Error photos not taken! TEST FAILED!"
  	exit 3	
	fi

adb shell am force-stop $cameraName

echo -e "\n CAMERA PHOTO TEST PASSED!"

#############################################################################################################

adb shell "am start $cameraName" #open camera
	if [[ $? -ne "0"  ]]
	  then
	  echo "Error camera cannot open! TEST FAILED!"
 	  exit 1
	fi
sleep 4

adb shell input tap 300 300 #focus the camera adb shell "input keyevent 80"

	if [[ $? -ne "0"  ]]
	then
  	echo "Error cant focus the camera! TEST FAILED!"
  	exit 2
	fi


adb shell uiautomator dump /sdcard/videoshot.xml ;adb pull /sdcard/videoshot.xml ; 

Line=$(cat videoshot.xml | grep -o -P '.{0,3}video_button.{0,295}' ) #Look for video_button from videostop.xml and save it in Line"
sleep 2
cat videoshot.xml | grep -o -P '.{0,3}video_button.{0,295}' > TEMPVideo #Save it in external file TEMPVideo
sleep 2
VideoCoord=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /clickable="true"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./TEMPVideo) #save coords in VideoCoord from TEMPVideo file

adb shell input tap $VideoCoord #tap on Video Button
	if [[ $? -ne "0"  ]]
	then
  	echo "Error cant open video recording!Button dont work! TEST FAILED!"
  	exit 4
	fi

###############################################################################################

adb shell uiautomator dump /sdcard/videostop.xml ;adb pull /sdcard/videostop.xml ;

Line=$(cat videostop.xml | grep -o -P '.{0,3}video_button.{0,295}') #Look for video_button from videostop.xml and save it in Line"
sleep 2
cat videostop.xml | grep -o -P '.{0,3}video_button.{0,295}' > TEMPVideo #Save it in external file TEMPVideo
sleep 2
VideoCoord=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /clickable="true"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./TEMPVideo) #save coords in VideoCoord from TEMPVideo file

adb shell input tap $VideoCoord #tap on Video Button to stop video recording
sleep 5

#adb shell "am force-stop $cameraName"


rm TEMPVideo
rm TEMPPhoto
rm videostop.xml
rm videoshot.xml
rm camerashot.xml
adb shell "rm /sdcard/videoshot.xml"
adb shell "rm /sdcard/videostop.xml"
adb shell "rm /sdcard/camerashot.xml"

echo -e "\n CAMERA VIDEO TEST PASSED!"

