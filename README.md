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
### Example For setting up HTTP redirector
```
./setup.sh myredirector.ca myteamserver.com http
```


## Sample of HTTP config generated
```
server {
    listen       80;
    server_name  myredirector.ca;
     
    # proxy to Team server
    location / {
        proxy_pass         http://myteamserver.com:80/;
        proxy_redirect     off;
        proxy_set_header   Host             $host;
    }
}
```
