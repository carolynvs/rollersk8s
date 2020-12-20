#!/bin/bash

if [ -z "$1" || ("$1" != "0" && "$1" != "1") ]; then
  echo "usage: ./rainbowdash.sh 0|1"
fi

REIMAGE=$1
MAC_ADDRESS="01-f4-4d-30-6d-5e-6c"
ROLE="leader"

if [ $REIMAGE == "0" ]
    if [ -f $MAC_ADDRESS ]; then
        rm $MAC_ADDRESS
    fi
    exit
else
    ln -f -s $ROLE $MAC_ADDRESS
fi

dhcp-host=F4:4D:30:6D:56:0C,rainbowdash,192.168.0.116
dhcp-host=F4:4D:30:6D:5E:6C,fluttershy,192.168.0.117
dhcp-host=F4:4D:30:6D:48:F6,twilightsparkle,192.168.0.118
dhcp-host=F4:4D:30:6D:48:08,applejack,192.168.0.119
dhcp-host=F4:4D:30:6D:61:51,pinkiepie,192.168.0.120