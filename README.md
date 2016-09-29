# redi
Automated reverse proxy redirectors 

## How to use

```
./setup.sh myredirector.ca myteamserver.com http
```

## Sample HTTP config
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
