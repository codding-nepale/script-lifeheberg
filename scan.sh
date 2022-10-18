#!/bin/bash

# variables

command=$1;
ip=$2;
range1=$3;
range2=$4;

# scanner

function tcpscan ()
{
    ip=$1
    range1=$2;
    range2=$3;
    if [[ -z "$ip" ]]; then
        echo 'Please put a IP'
    else
        if [[ $ip =~  ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            
            if [[ -z "$range1" || ! "$range1" =~ ^[0-9]+$ ]]; then
                echo 'Please put a start port'
            else
                if [[ -z "$range2" ]]; then                    
                    echo 'Please put a end port or put --no-range'
                else
                    if [[ "$range2" =~ ^[0-9]+$ ]]; then
                        for port in $(seq "$range1" "$range2");
                        do
                            timeout 1 bash -c "</dev/tcp/$ip/$port && echo Port $port is open || echo Port $port is closed > /dev/null" 2>/dev/null || echo Connection timeout > /dev/null
                        done
                    else
                        if [[ ! "$range2" =~ ^[0-9]+$ || "$range2" == '--no-range' ]]; then
                            timeout 1 bash -c "</dev/tcp/$ip/$range1 && echo Port $range1 is open || echo Port $range1 is closed" 2>/dev/null || echo "Connection timeout"
                        fi
                    fi
                fi
            fi
        else
            echo "Please put a valid IP"
        fi
    fi
}

tcpscan "$ip" "$range1" "$range2";

# commands
function cli ()
{
    if [[ "$command" == 'help' ]]; then
            echo "
                Usage: putils scan [<port>...] [scan-OPTIONS]

                The scan command allows you to scan the ports that are open on the designated IP

                [scan command options]
                    --no-range      Allows you to scan only one port on the designated IP
                "
    else
        echo "
        Usage: putils scan [<port>...] [scan-OPTIONS]

        The scan command allows you to scan the ports that are open on the designated IP

        [scan command options]
            --no-range      Allows you to scan only one port on the designated IP
        "
    fi
}

cli "$command";