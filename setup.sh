#!/bin/bash

echo [+] updating
apt-get update

echo [+] installing nginx
apt-get install nginx

echo [+] starting configuration
rm /etc/nginx/sites-enabled/default

CONFIGFILE="redirector.conf"

#for https redirectors
if [ "$3" = "https" ]
then
 echo [+] https is selected
 CONFIGFILE="redirector-ssl.conf"
 echo [+] downloading certbot to generate certificates
 wget https://dl.eff.org/certbot-auto
 chmod a+x certbot-auto
 echo [+] generating certifcates
 ./certbot-auto certonly --standalone -d $1 --agree-tos --register-unsafely-without-email
fi

echo [+] generating config file
sed 's/www.you_redirector_domain_here.com/'$1'/g; s/www.your_team_server_domain_here.com/'$2'/g' $CONFIGFILE > /etc/nginx/sites-enabled/redirector.conf

echo [+] starting nginx
service nginx start
service nginx reload
