# redi
Automated reverse proxy redirectors 

## How to use

```
git clone https://github.com/taherio/redi.git
cd redi
chmod u+x setup.sh
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
