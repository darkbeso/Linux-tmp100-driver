#!/bin/bash

USAGE()
{
echo "Usage"
echo "Pass an account. example: fb.sh A or fb.sh B"
exit
}

dump_pull()
{
adb shell uiautomator dump /sdcard/WIFI_networks.xml 
adb pull /sdcard/WIFI_networks.xml
sleep 2
}

################################################################################################################################
#Setup script with A or B fb acc
adb wait-for-device
if [[ "$#" -ne 1 ]]
then
  USAGE
fi

case "$1" in
"A")
ID="499655422"
;;
"B") 
ID="499655423"
;;
*)
echo "Your are drunk!!"
exit
esac

################################################################################################################################
#Wait for device to boot up

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
#Connect to wifi network
sleep 5
adb shell input keyevent 66; adb shell input keyevent 66 #enter (click OK on first displayed error msg "Contact manufacturer..")
adb shell input swipe 650 750 650 150 75 #from up to down, 75 is ms duration of the tap
sleep 1
	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Other..."[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 1
	adb shell input text 'Cisco_mms_5G'
	
	dump_pull 
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="None"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
#sleep 1
	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="WPA2"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 1
	adb shell input keyevent 61 #tab	
	adb shell input text 'xxxxlllll'

	dump_pull 
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Join"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 5
	dump_pull 
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Next"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 2
################################################################################################################################
#Login with FB acc

	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Log in with Facebook"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 1
	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Use Facebook Password Instead"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)	
	adb shell input tap $coords

adb shell input text "$ID"
adb shell input keyevent 66 #enter
sleep 1
adb shell input text "AlohaB8"
adb shell input keyevent 66 #enter
sleep 2

################################################################################################################################
#Startup Setup
adb shell input keyevent 66 #enter (Next Button be4 Giving portal's name list)
sleep 1
adb shell input tap 1000 500 #Choose first of the list

	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Next"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 15
	dump_pull	
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Skip"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 2
	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Next"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 1
	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Not Now"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 1 
	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Next"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords
sleep 1
	adb shell input tap $coords #Again same (Next) button name on the same position

	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Not Now"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords	

	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Continue"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords	

	dump_pull
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Explore Home"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml)
	adb shell input tap $coords

for i in `seq 1 6`;
do
adb shell input keyevent 66; #enter
sleep 0.5
done	

################################################################################################################################

rm WIFI_networks.xml
adb shell "rm /sdcard/WIFI_networks.xml"
