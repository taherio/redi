#!/bin/bash

echo [+] updating
apt-get update

echo [+] installing nginx
apt-get --assume-yes install nginx

echo [+] starting configuration
service nginx stop
rm /etc/nginx/sites-enabled/default

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
 DOMAINS=( $(echo $1 | tr ',' ' ') )
 DOMAINS_FOR_CERT=( $(echo $1 | sed 's/,/ -d /g') )

 ./certbot-auto certonly --standalone -d ${DOMAINS_FOR_CERT[@]} --agree-tos --register-unsafely-without-email --non-interactive --expand
fi

for DOMAIN in "${DOMAINS[@]}"
do
 echo [+] generating config file for $DOMAIN
 sed 's/www.you_redirector_domain_here.com/'$DOMAIN'/g; s/www.your_team_server_domain_here.com/'$2'/g' $CONFIGFILE > /etc/nginx/sites-enabled/redirector-$DOMAIN.conf
done

echo [+] starting nginx
service nginx start
service nginx reload
