#!/bin/bash
config=/etc/certbot-post-renewal-reload/config.reload.cf
config_location=/etc/certbot-post-renewal-reload/config.location.cf
compose="docker-compose"
def=".yml"

if [ -f "$config_location" -a -f "$config" ]; then
    source $config
    
    if [ -d "$certs_path" -a -d "$last_reload_path" ]; then
        certs_path="${certs_path%/}"
        last_reload_path="${last_reload_path%/}"

        mapfile -t locations < $config_location

        for location in "${locations[@]}"
        do
            path=$(echo $location | sed "s/ //g")
            path="${path%/}"
            path="${path#/}"

            if [ -f "/$path/$compose$def" ]; then
                mapfile -t dclines < /$path/$compose$def

                vhline=$(printf "%s\n" "${dclines[@]}" | grep -P -i "virtual_host")
                vhval="$(cut -d'=' -f2 <<< "$vhline")"
                vh=$(echo $vhval | sed "s/,/ /g")

                domains=($vh)
                reload=""

                for domain in "${domains[@]}"
                do
                    if [ -f "$certs_path/$domain.crt" ]; then
                        current_date=$(date -r "$certs_path/$domain.crt")

                        if [ ! -f "$last_reload_path/$domain" ]; then
                            echo $current_date > "$last_reload_path/$domain"
                        fi

                        last_reload_date=$(date -d "$(cat $last_reload_path/$domain)")

                        if [ $(date -d "$current_date" +%s) -gt $(date -d "$last_reload_date" +%s) ]; then
                            echo $current_date > $last_reload_path/$domain
                            reload=$domain
                        fi
                    else
                        echo "error: certificate $certs_path/$domain.crt doesn't exists."
                    fi
                done

                if [ $reload ]; then
                    echo "info: reloading location /$path hosts certificates for $(printf "%s, " "${domains[@]}")."
                    
                    cd /$path
                    $compose down
                    $compose up -d
                else
                    echo "info: all certificates for $(printf "%s, " "${domains[@]}") at location /$path are up to date."
                fi
            else
                echo "error: $compose$def not found at /$path."
            fi
        done
    else
        echo "error: certs path $certs_path or last reload date path $last_reload_path not found."
    fi
else
    echo "error: config file $config_location or $config doesn't exists."
fi