#!/bin/bash

now=$(date +"%s")

echo [+] updating
apt-get update

if [ "$2" = "dns" ]
then
  echo [+] installing dnsmasq
  apt-get --assume-yes install dnsmasq
  echo [+] starting configuration
  service dnsmasq stop
  mv /etc/default/dnsmasq /etc/default/dnsmasq_bak_${now}
  mv /etc/dnsmasq.conf /etc/dnsmasq.conf_bak_${now}

  echo [+] generating config file for teamserver $1
  CONFIGFILE="redirector-dns.conf"
  sed 's/www.your_team_server_domain_here.com/'$1'/g' $CONFIGFILE > /etc/dnsmasq.conf
  cp redirector-dns-defaults.conf /etc/default/dnsmasq
  echo [+] starting dnsmasq
  service dnsmasq start

else

  #for http/https redirectors
  if [ "$3" = "https" ] || [ "$3" = "http" ]
  then
   echo [+] installing nginx
   apt-get --assume-yes install nginx

   echo [+] starting configuration
   service nginx stop
   mv /etc/nginx/sites-enabled/ /etc/nginx/sites-enabled_bak_${now}/
   mkdir /etc/nginx/sites-enabled

   CONFIGFILE="redirector.conf"
   DOMAINS=( $(echo $1 | tr ',' ' ') )

   #for https redirectors
   if [ "$3" = "https" ]
   then
    echo [+] https is selected
    CONFIGFILE="redirector-ssl.conf"
    echo [+] downloading certbot to generate certificates
    wget https://dl.eff.org/certbot-auto
    chmod a+x certbot-auto
    echo [+] generating certifcates
    mv /etc/letsencrypt/ /etc/letsencrypt_bak_${now}/
    DOMAINS=( $(echo $1 | tr ',' ' ') )
    for DOMAIN in "${DOMAINS[@]}"
    do
     ./certbot-auto certonly --standalone -d $DOMAIN --agree-tos --register-unsafely-without-email --non-interactive --expand
    done
   fi

   for DOMAIN in "${DOMAINS[@]}"
   do
    if [ "$3" = "https" ] && [ ! -f /etc/letsencrypt/live/$DOMAIN/cert.pem ]; then
     echo -e "\e[91m[-] Certificate generation failed for domain $DOMAIN \033[0m"
     echo -e "\e[91m[-] Will not generate nginx config for this domain \033[0m"
    else
     echo [+] generating config file for $DOMAIN
     sed 's/www.you_redirector_domain_here.com/'$DOMAIN'/g; s/www.your_team_server_domain_here.com/'$2'/g' $CONFIGFILE > /etc/nginx/sites-enabled/redirector-${DOMAIN}.conf
    fi
   done

   echo [+] starting nginx
   service nginx start
   service nginx reload
  fi

fi
