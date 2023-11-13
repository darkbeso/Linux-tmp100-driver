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

adb reboot
adb wait-for-device

Loaded=$(adb shell getprop sys.boot_completed | tr -d '\r')

while [ "$Loaded" != "1" ]; 
do
        sleep 2
        Loaded=$(adb shell getprop sys.boot_completed | tr -d '\r')
done
sleep 6

################################################################################################################################

adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings # open wifi settings
sleep 2
adb shell svc wifi enable #adb shell input keyevent 20; adb shell input keyevent 23 #turn on wifi   
sleep 6

Count=$(cat testconfig | grep -i "NetworksCount" | cut -d "|" -f 2)

for i in `seq 1 $Count`
do

sleep 2
Found=0
while [[ $Found -ne "1" ]]
do
	adb shell input swipe 650 750 650 150 75 #from up to down, 75 is ms duration of the tap
	sleep 1
	adb shell uiautomator dump /sdcard/WIFI_networks.xml ;adb pull /sdcard/WIFI_networks.xml ;  
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Add network"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml) ; adb shell input tap $coords #finds coords of Add network

	adb shell uiautomator dump /sdcard/addnetwork.xml 
	adb pull /sdcard/addnetwork.xml
	sleep 3
	Addnetwork=$(cat addnetwork.xml | grep "Add network" | wc -l) #Search for Add network 1-found
		if [[ $Addnetwork -lt "1" ]] #If NO go back
		then

		adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings
		sleep 1

		else
		Found=1
		fi
done

export NetworkSSID=$(cat testconfig | grep -i "NetworkSSID$i" | cut -d "|" -f 2) #take NetworkSSID from testconfig fail
NetworkPass=$(cat testconfig | grep -i "NetworkPass$i" | cut -d "|" -f 2) #take NetworkPass from testconfig fail

sleep 2
adb shell uiautomator dump /sdcard/security.xml ;adb pull /sdcard/security.xml ; coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="None"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./security.xml) ; adb shell input tap $coords #finds coords and click on Security None to open fall menu
sleep 5


###########################################################################################################################
adb shell uiautomator dump /sdcard/wpa.xml
adb pull /sdcard/wpa.xml

Line=$(cat wpa.xml | grep -o -P '.{0,3}WPA.{0,340}') #save the 3 charachters before WPA and 340 after it in Line 
sleep 2
cat wpa.xml | grep -o -P '.{0,3}WPA.{0,340}' > TEMP #save bounds from wpa.xml into TEMP fail
sleep 2
WPACoord=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /clickable="true"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./TEMP) #save coords in WPACoord

	adb shell input tap $WPACoord #tap on WPA/WPA2 PSK

sleep 5
	adb shell input text "$NetworkSSID"
	adb shell input keyevent 66 #enter
sleep 2
	adb shell input keyevent 61 #tab
sleep 1

sleep 2
	adb shell input text "$NetworkPass"
	adb shell input keyevent 66 # enter


sleep 10
IsConnected=$(adb shell dumpsys wifi | grep "$NetworkSSID" | grep  "state: CONNECTED" | wc -l) #check connection
	if [[ "$IsConnected" -lt "1"  ]] #>=1-Connected 0-Disconnected
	then
  	echo "Error wifi $NetworkSSID not connected! TEST FAILED!"
  	exit 1
	fi
echo -e "\n Successfully connected to $NetworkSSID" #-e enables \n for new line

adb shell ping -c 3 www.google.com #check internet


adb shell input swipe 650 250 650 600 75 # from down to up, 75 is the speed of sliding
sleep 5
adb shell uiautomator dump /sdcard/WIFI_networks.xml ;adb pull /sdcard/WIFI_networks.xml ; coords=$(perl -ne '$network=$ENV{'NetworkSSID'}; printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="$network"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml) ; adb shell input tap $coords #finds coords and taps on the connected network must be exported before

sleep 5
adb shell uiautomator dump /sdcard/WIFI_networks.xml ;adb pull /sdcard/WIFI_networks.xml ; coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="FORGET"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' ./WIFI_networks.xml) ; adb shell input tap $coords #find cords of forget button and taps it

done

rm WIFI_networks.xml
rm security.xml
rm wpa.xml
rm addnetwork.xml
rm TEMP
adb shell "rm /sdcard/WIFI_networks.xml"
adb shell "rm /sdcard/security.xml"
adb shell "rm /sdcard/wpa.xml"
adb shell "rm /sdcard/addnetwork.xml"


echo -e "\n WiFi Test Successfull!"
