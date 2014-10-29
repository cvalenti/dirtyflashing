#!/bin/bash

# TODO
# Recovery mode
# Getopts
# Usage
# IP Discovery

usage () {
cat << _EOF_
$PROGNAME: A tool for flashing Access Points
Usage: $PROGNAME flash -s </path/to/binary> -i <ip_address>

Options:
  -h              				Print basic help and exit
  -s </path/to/binary>   	Firmware file
  -i <ip_address>					IP address of your Access Point (default 192.168.1.20)
_EOF_
}

install_tftp-hpa(){
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

PROGNAME=${0##*/}
IPADDR="192.168.1.20"

while getopts "hs:i:" OPTION; do
  case $OPTION in
    h)
      usage
      exit
      ;;
    s)
      BINPATH=$OPTARG
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

cp $BINPATH `pwd`
BINFILE=`basename $BINPATH`

sudo chmod 777 /dev/ttyACM0

stty -F /dev/ttyACM0 raw ispeed 15200 ospeed 15200 cs8 -ignpar -cstopb -echo

echo 'd' > /dev/ttyACM0

sleep 1

echo 'o' > /dev/ttyACM0

echo 'In attesa del Bootloader'

sleep 12

echo 'n' > /dev/ttyACM0

tftp -v $IPADDR -m binary -c put $BINFILE

rm $BINFILE