#!/bin/bash

#SET THE FOLLOWING

HOSTNAME=mydyndns.com
SSH_PORT=22
WIREGUARD_PORT=5246

#IF IT DOES NOT WORK, AT LEAST ON UBUNTU INSTALL, bind-utils to get the host command

#Create a cron /15 * * * * root bash /path/to/dynamicdnsupdater.sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi
new_ip=$(host $HOSTNAME | head -n1 | cut -f4 -d ' ')
old_ip=$(/usr/sbin/ufw status | grep $HOSTNAME | head -n1 | tr -s ' ' | cut -f3 -d ' ')
if [ "$new_ip" = "$old_ip" ] ; then
    echo IP address has not changed
else
    if [ -n "$old_ip" ] ; then
        /usr/sbin/ufw delete allow from $old_ip to any port $SSH_PORT
        /user/sbin/ufw delete allow from $old_ip to any port $WIREGUARD_PORT
    fi
    /usr/sbin/ufw allow from $new_ip to any port $SSH_PORT comment $HOSTNAME
    /usr/sbin/ufw allow from $new_ip to any port $WIREGUARD_PORT comment $HOSTNAME
    echo iptables have been updated
fi
