#!/bin/bash

date

function generate_view(){
	adb shell uiautomator dump /sdcard/view.xml
	adb pull /sdcard/view.xml /tmp/
}

function go_down() {
	adb shell input touchscreen swipe 422 1000 422 1
}

function find_other() {
	# swipe to the bottom
	go_down

	# generate view.xml in /tmp/
	generate_view

	# get 'Other...' button coordinates
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Other..."[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' /tmp/view.xml)

	# tap 'Other...' button
	adb shell input tap $coords
	
	# generate view from prompt
	generate_view

	# check if 'Other Network' exist in prompt
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Other Network"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' /tmp/view.xml)
	
	# if 'Other Network' does not exist generate view and click 'Cancel'
	if [[ -z $coords ]]; then
		# tap 'Cancel' button
		adb shell input keyevent 4
		adb shell input keyevent 4
	fi	
}

function wait_for_device() {
	adb wait-for-device

	A=$(adb shell getprop sys.boot_completed | tr -d '\r')

	while [ "$A" != "1" ]; do
	    sleep 2
	    A=$(adb shell getprop sys.boot_completed | tr -d '\r')
	done
	
	sleep 20
}

adb wait-for-device

while [ 1 ]
do
	echo '-----------------------------------------'
	echo 'factory reset'
	echo '-----------------------------------------'
	adb reboot bootloader
	sleep 15
	./fastboot -w
	fastboot reboot;

	echo '-----------------------------------------'
	echo 'waiting for device'
	echo '-----------------------------------------'
	wait_for_device
	
	echo '-----------------------------------------'
	echo 'connect to internet'
	echo '-----------------------------------------'
	# generate view and check if 'Other...' exist
	generate_view
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Other Network"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' /tmp/view.xml)

	
	echo '-----------------------------------------'
	echo 'finding other'
	echo '-----------------------------------------'
	while [ -z "$coords" ]
	do
		find_other
	done

	echo '-----------------------------------------'
	echo 'enter wifi information'
	echo '-----------------------------------------'
	# enter Network name
	adb shell input text 'Cisco_mms_5G'

	#tap on 'None'
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="None"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' /tmp/view.xml)
	adb shell input tap $coords

	#tap on 'WPA2'
	generate_view
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="WPA2"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' /tmp/view.xml)
	adb shell input tap $coords

	# switch to 'Enter password'
	adb shell input keyevent 61

	# enter password
	adb shell input text 'xxxxlllll'

	#tap on 'Join'
	generate_view
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Join"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' /tmp/view.xml)
	adb shell input tap $coords
	sleep 10

	echo '-----------------------------------------'
	echo 'connected to wifi, tap on Next'
	echo '-----------------------------------------'
	#tap on 'Next'
	generate_view
	coords=$(perl -ne 'printf "%d %d\n", ($1+$3)/2, ($2+$4)/2 if /text="Next"[^>]*bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"/' /tmp/view.xml)
	adb shell input tap $coords
	
	date
done

