This container has liveproxy and streamlink included. It makes it super easy to take a stream from streamlink and push it through liveproxy, which can then be used in VLC or xteve.

```
liveproxy:
  image: sparticuz/liveproxy:latest
  ports:
    - 53422:53422
```
