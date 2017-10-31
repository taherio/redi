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

CONFIGFILE="redirector-ssl-stealth.conf"
DOMAINS=( $(echo $1 | tr ',' ' ') )
REGEX=$(echo $(cat $4 | grep uri | cut -d '"' -f2) | sed 's/\//\\\//g' | sed 's/\ /\|/g')

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

for DOMAIN in "${DOMAINS[@]}"
do
 if [ ! -f /etc/letsencrypt/live/$DOMAIN/cert.pem ]; then
  echo -e "\e[91m[-] Certificate generation failed for domain $DOMAIN \033[0m"
  echo -e "\e[91m[-] Will not generate nginx config for this domain \033[0m"
 else
  echo [+] generating config file for $DOMAIN
  sed 's/www.you_redirector_domain_here.com/'$DOMAIN'/g; s/www.your_team_server_domain_here.com/'$2'/g; s/www.proxied_domain_here.com/'$3'/g; s/regex_from_profile/'$REGEX'/g' $CONFIGFILE > /etc/nginx/sites-enabled/redirector-${DOMAIN}.conf
 fi
done

echo [+] starting nginx
service nginx start
service nginx reload
