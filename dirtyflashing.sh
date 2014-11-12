#!/bin/bash

# TODO
# Recovery mode
# IP Discovery: check if there is a route for <ip_access>

usage() {
cat << _EOF_
$PROGNAME: A tool for flashing Access Points using USB RLY02
Usage: $PROGNAME [OPTIONS]

Options:
  -h                      Print basic help and exit
  -s </path/to/binary>    OpenWRT Firmware path
  -u <URL>                OpenWRT Firmware URL
  -i <ip_address>         IP address of your Access Point (default 192.168.1.20)
_EOF_
}

install_tftp-hpa() {
  echo -n "tftp-hpa is not installed: do you want to install now? (Y/n) "
  read ans_install
  case $ans_install in
    [yY] | [yY][eE][sS])
      #define distro and install rdesktop
      if [ -f /etc/lsb-release ]; then
        apt-get install tftp-hpa
      else
        echo "Only debian-based disto is currently supported. Stay in touch for more implementations"
        exit 1
      fi
      ;;
    *)
      echo "Exit now"
      exit 1
      ;;
  esac
}

wait_bootloader() {
  echo 'In attesa del Bootloader'
  sleep 12
}

check_ping() {
  ping -c 1 -W 3 $IPADDR >/dev/null 2>&1
  RET=$?
  if [ $RET -ne 0 ]; then
    echo "Unable to find device, check your IP connection"
    exit 1
  fi
  sleep 0.5
}

use_usb_rly() {
  sudo chmod 777 /dev/ttyACM0
  stty -F /dev/ttyACM0 raw ispeed 15200 ospeed 15200 cs8 -ignpar -cstopb -echo
  # All relays on
  echo 'd' > /dev/ttyACM0
  sleep 1
  # Turn relay 1 off
  echo 'o' > /dev/ttyACM0
  wait_bootloader
  # All relays off
  echo 'n' > /dev/ttyACM0
}

PROGNAME=${0##*/}
IPADDR="192.168.1.20"
URL=""
BINPATH=""

while getopts "hs:i:u:" OPTION; do
  case $OPTION in
    h)
      usage
      exit
      ;;
    s)
      BINPATH=$OPTARG
      ;;
    u)
      URL=$OPTARG
      ;;
    i)
      IPADDR=$OPTARG
      ;;
    *)
      echo "Invalid arguments"
      usage
      exit 1
      ;;
  esac
done


if [[ ! `dpkg -l | grep tftp-hpa` ]]; then
  install_tftp-hpa
fi

if [ $URL ]; then
  wget -q $URL -O `pwd`/dirtyflashingfirmware.bin
  BINFILE=`pwd`/dirtyflashingfirmware.bin
elif [ $BINPATH ]; then
  cp $BINPATH `pwd`
  BINFILE=`basename $BINPATH`
else
  echo "Please enter a Firmware file"
  exit 1
fi

use_usb_rly

check_ping

tftp -v $IPADDR -m binary -c put $BINFILE

rm $BINFILE


