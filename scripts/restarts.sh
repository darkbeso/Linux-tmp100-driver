#!/bin/bash
for i in `seq 1 1000` 
do  adb wait-for-device 
while [[ $( adb shell getprop sys.boot_completed ) -ne "1" ]] 
do sleep 1 
done
adb reboot 
done
