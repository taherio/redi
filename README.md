# redi
Automated reverse proxy redirectors setup, compatible with CobaltStrike beacon. 

## Advantages
- Auto SSL setup for HTTPS using letsencrypt certbot
- Auto nginx configuration
- Access logs for redirector (default nginx logs)
- Fine control over HTTP headers by customizing nginx configuration. 
- SSL offloading possible, so you can have SSL beacon delivered to a backend HTTP listener !!
- Allows for multiple valid HTTPS redirectors setup
- Adds original source ip to user-agent header for easy tracking. 

![alt tag](https://github.com/taherio/random/raw/38641d74f0628a26142b121e62b393e96cac156a/image.png)

## How to use

```
git clone https://github.com/taherio/redi.git
cd redi
chmod u+x setup.sh
./setup.sh <redirector domain> <teamserver ip/domain> <http/https>
```
### Example For setting up HTTPS redirector
```
./setup.sh myredirector.ca myteamserver.com https
```


## Sample of HTTPS config generated
```
server {
    listen 443 ssl;
    server_name myredirector.ca;

    ssl on;
    ssl_certificate 	/etc/letsencrypt/live/www.you_redirector_domain_here.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/www.you_redirector_domain_here.com/privkey.pem;

    location / {
        proxy_pass         https://myteamserver.com:443/;
        proxy_redirect     off;
        proxy_set_header   Host             $host;
        proxy_set_header   "User-Agent" "${http_user_agent} - Original IP ${remote_addr}";
    }
}
```
