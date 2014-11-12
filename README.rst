=====================================================
Dirtyflashing - Flash your Access Point like a charm
=====================================================

Dirtyflashing is a tiny script that use USB-RLY02 [*]_ for setting AP in reset mode and tftp protocol for putting firmware on it.

Usage
-----

::

  dirtyflashing.sh [OPTIONS]

  Options:
    -h                      Print basic help and exit
    -s </path/to/binary>    OpenWRT Firmware path
    -u <URL>                OpenWRT Firmware URL
    -i <ip_address>         IP address of your Access Point (default 192.168.1.20)

Tested Access Points
--------------------

* Ubiquiti PicoStation2

.. [*] http://www.robot-electronics.co.uk/htm/usb_rly02tech.htm
