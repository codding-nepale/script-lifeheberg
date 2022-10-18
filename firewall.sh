#!/usr/bin/bash

WORKPLACE="/usr/putils/firewall"
ACTION="$1"
BLOCKFORMAT="$2"
TARGET="$3"


function check_workplace()
{
    WORKPLACE="$1"

    if [[ ! -e "$WORKPLACE" ]]; then
        echo "$WORKPLACE doesn't exist, creating..."
        mkdir -p "$WORKPLACE"
    else
        if [ ! -d "$WORKPLACE" ]; then
            echo "Alert: $WORKPLACE is a file exiting..."
            exit 1
        else
            echo "$WORKPLACE is a directory... processing"
        fi
    fi
}

function get_country()
{
    WORKPLACE="$1"
    COUNTRY="$2"
    BASE_URL="http://www.ipdeny.com/ipblocks/data/aggregated"

    wget -q $BASE_URL/$COUNTRY-aggregated.zone -O $WORKPLACE/$COUNTRY.zone
}

function blockip()
{
    IP="$1"
    read -p "Do you have PVE (Proxmox Virtual Environement) ? [Y/n]" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        iptables -I INPUT -s "$IP" -j DROP -v
        iptables -t mangle -A PREROUTING -s "$IP" -j DROP -v
    else
        echo "Ok you don't have PVE (Proxmox Virtual Environement) ?"
        iptables -I INPUT -s "$IP" -j DROP -v
    fi

}

function unblockip()
{
    IP="$1"
    read -p "Do you have PVE (Proxmox Virtual Environement) ? [Y/n]" -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        iptables -D INPUT -s "$IP" -j DROP -v
        iptables -t mangle -D PREROUTING -s "$IP" -j DROP -v
    else
        echo "Ok you don't have PVE (Proxmox Virtual Environement) ?"
        iptables -D INPUT -s "$IP" -j DROP -v
    fi
}

function core()
{
    ACTION="$1"
    BLOCKFORMAT="$2"
    TARGET="$3"
    WORKPLACE="$4"

    if [[ "$BLOCKFORMAT" = "country" ]]; then
        get_country "$WORKPLACE" "$TARGET"
        HOWMANYLINES=$(cat "$WORKPLACE/$TARGET.zone" | wc -l)

        if [[ "$ACTION" = "block" ]]; then
            SECONDS="0"
            echo "Processing blacklist $HOWMANYLINES IPS for $TARGET country... please wait"
            for LINE in $(cat "$WORKPLACE/$TARGET.zone"); do
                blockip $LINE > /dev/null
            done
            echo "Done! Country $TARGET ($HOWMANYLINES IPS) blacklist in $SECONDS seconds"
        elif [[ "$ACTION" = "unblock" ]]; then
            SECONDS="0"
            echo "Processing blacklist $HOWMANYLINES IPS for $TARGET country... please wait"
            for LINE in $(cat "$WORKPLACE/$TARGET.zone"); do
                unblockip $LINE > /dev/null
            done
            echo "Done! Country $TARGET ($HOWMANYLINES IPS) unblacklist in $SECONDS seconds"
        else
            echo "$ACTION invalid, exiting..."
            exit 1
        fi
    elif [[ "$BLOCKFORMAT" = "ip" ]]; then
        if [[ "$TARGET" =~ (([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5])\.([01]{,1}[0-9]{1,2}|2[0-4][0-9]|25[0-5]))$ ]]; then
            echo "$IP address $TARGET is valid"

            if [[ $TARGET != 0.0.0.0 ]]; then
                if [[ "$ACTION" = "block" ]]; then
                            SECONDS="0"
                            echo "Processing blacklist $TARGET IP... please wait"
                            blockip $TARGET > /dev/null
                            echo "Done! $TARGET IP blacklist in $SECONDS seconds"
                        elif [[ "$ACTION" = "unblock" ]]; then
                            SECONDS="0"
                            echo "Processing unblacklist $TARGET IP... please wait"
                            unblockip $TARGET > /dev/null
                            echo "Done! $TARGET IP unblacklist in $SECONDS seconds"
                        else
                            echo "$ACTION invalid, exiting..."
                            exit 1
                        fi
                    else
                        echo "You can't do this!"
                    fi
                elif [[ "$TARGET" =~ (((25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|1?[0-9][0-9]?))(\/([8-9]|[1-2][0-9]|3[0-2]))([^0-9.]|$) ]]; then
                    echo "CIDR range $TARGET is valid"

                    if [[ $TARGET != 0.0.0.0 ]]; then
                        if [[ "$ACTION" = "block" ]]; then
                            SECONDS="0"
                            echo "Processing blacklist $TARGET IP... please wait"
                            blockip $TARGET > /dev/null
                            echo "Done! $TARGET IP blacklist in $SECONDS seconds"
                        elif [[ "$ACTION" = "unblock" ]]; then
                            SECONDS="0"
                            echo "Processing unblacklist $TARGET IP... please wait"
                            unblockip $TARGET > /dev/null
                            echo "Done! $TARGET IP unblacklist in $SECONDS seconds"
                        else
                            echo "$ACTION invalid, exiting..."
                            exit 1
                        fi
                    else
                        echo "You can't do this!"
                    fi
                else
                    echo "ERROR : $TARGET is an invalid IP address or CIDR format... exiting"

                    exit 1
                fi
            else
                echo "Block format : $BLOCKFORMAT invalid, exiting"
                exit 1
            fi
}

function action()
{
    ACTION="$1"
    BLOCKFORMAT="$2"
    TARGET="$3"
    WORKPLACE="$4"

    check_workplace "$WORKPLACE"

    if [[ "$ACTION" = "block" ]]; then
        core $ACTION $BLOCKFORMAT $TARGET
    elif [[ "$ACTION" = "unblock" ]]; then
        core $ACTION $BLOCKFORMAT $TARGET
    elif [[ "$ACTION" = "help" ]]; then
        echo "
            Usage: firewall [firewall-OPTIONS] [<IP or country>...]

            The firewall command allows you to block, unblock IPs or countries thanks to a series of easy to use options

            [function of the firewall command]
                {action} => block or unblock
                {blockformat} => ip or country
                {target} => (192.168.x.x), (192.168.x.x/24) or country code (ex: encountry code)
            "
    else
        echo "Invalid action, please retry..."
        exit 1
    fi
}

action $ACTION $BLOCKFORMAT $TARGET $WORKPLACE