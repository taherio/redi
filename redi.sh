#!/bin/bash

now=$(date +"%s")

echo [+] updating
apt-get update

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
