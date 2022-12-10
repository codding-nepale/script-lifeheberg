#!/usr/bin/bash

WORKPLACE="$1"
function blockip()
{
    IP="$1"
    read -p "Do you have PVE (Proxmox Virtual Environement) ? [Y/n]" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        iptables -I INPUT -s "$IP" -j DROP -v
        iptables -t mangle -A PREROUTING -s "$IP" -j DROP -v
    else
        echo "Ok you don't have PVE (Proxmox Virtual Environement)"
        iptables -I INPUT -s "$IP" -j DROP -v
    fi

}

function core()
{
    WORKPLACE="$1"
    for LINE in $(cat $WORKPLACE); do
        blockip $LINE > /dev/null
    done
}

core $WORKPLACE
