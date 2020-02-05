#!/bin/bash
config=/etc/certbot-renewed-copy/config.cf
source=/etc/letsencrypt/live
certfile=fullchain.pem
keyfile=privkey.pem

if [ -e "$config" ]; then
    mapfile -t lines < $config

    certsline=$(printf "%s\n" "${lines[@]}" | grep -P -i "^certificates")
    certsval="$(cut -d'=' -f2 <<< "$certsline")"
    certsvaltrim=$(echo $certsval | sed "s/,/ /g")

    certs=($certsvaltrim)
    certscount=${#certs[@]}

    destline=$(printf "%s\n" "${lines[@]}" | grep -P -i "^destination")
    destval="$(cut -d'=' -f2 <<< "$destline")"

    dest=$(echo $destval | sed "s/ //g")
    dest=${dest%/}

    if [ $certscount -gt 0 -a -d "$dest" ]; then
        for cert in "${certs[@]}"
        do
            if [ -e $source/$cert/$certfile -a -e $source/$cert/$keyfile ]; then
                cp --preserve=timestamps $source/$cert/$certfile $dest/$cert.crt
                cp --preserve=timestamps $source/$cert/$keyfile $dest/$cert.key
                
                echo "certificates $source/$cert/$certfile and $source/$cert/$keyfile were copied to $dest."
            else
                echo "error: certificate $source/$cert/$certfile or $source/$cert/$keyfile doesn't exists."
            fi
        done
    else
        echo "error: certificates to copy aren't specified or destination doesn't exists."
    fi
else
    echo "error: config file $config not found."
fi
