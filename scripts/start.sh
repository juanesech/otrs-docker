#!bin/bash

count=0
while [ `service apache2 status | awk 'BEGIN { FS = " " } ; { print $NF }'` = "failed!" ]; do
    service apache2 start
    count=$(( count + 1 ))
    sleep 2
    if [ $count -gt 4 ]; then
        echo "Can't start apache service"
        exit 1
    fi
done

tail -f /var/log/apache2/error.log