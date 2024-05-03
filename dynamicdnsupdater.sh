#!/bin/bash

# Configuration
HOSTNAME=host.domainname.tld
SSH_PORT=22
TIMESTAMP=`date "+%Y-%m-%dT%H:%M:%S"`

# Cronjob
#*/15 * * * * root bash /path/to/dynamicdnsupdater.sh

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Variables
new_ip=$(host $HOSTNAME | sed -n 2p | cut -f4 -d ' ')
old_ip=$(/usr/sbin/ufw status | grep $HOSTNAME | head -n1 | tr -s ' ' | cut -f3 -d ' ')

# Logic
if [ "$new_ip" = "$old_ip" ] ; then
    echo "$TIMESTAMP IP address has not changed - $old_ip" >> /var/log/dynamicdnsupdater.log
else
    if [ -n "$old_ip" ] ; then
        /usr/sbin/ufw delete allow from $old_ip to any port $SSH_PORT
    fi
    /usr/sbin/ufw allow from $new_ip to any port $SSH_PORT comment $HOSTNAME
    echo "$TIMESTAMP IP address has changed, UFW set from $old_ip to $new_ip" >> /var/log/dynamicdnsupdater.log

fi
