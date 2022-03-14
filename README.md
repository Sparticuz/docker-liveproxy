This container uses liveproxy to make it super easy to take a stream and push it through liveproxy, which can then be used in VLC or xteve.

docker-compose.yml
```
liveproxy:
  image: sparticuz/liveproxy:latest
  ports:
    - 53422:53422
```

To use this container, start it up, then you can follow the instructions on liveproxy's repo: https://github.com/back-to/liveproxy
