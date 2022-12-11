#!/usr/bin/bash

URL="https://raw.githubusercontent.com/codding-nepale/script-lifeheberg/main/other/license.php"
WORKPLACE="/var/www/whmcs/modules/servers/proxmoxVPS"

rm -rf $WORKPLACE/license.php
wget -q $URL -O $WORKPLACE/license.php