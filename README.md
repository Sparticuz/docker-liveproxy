# docker-liveproxy

A Docker container that bridges livestreams to HTTP using [LiveProxy](https://github.com/back-to/liveproxy). It takes a streaming URL (YouTube, Twitch, and hundreds of other sites), proxies the video stream, and serves it over a plain HTTP endpoint. This allows media players like VLC, Kodi, or IPTV middleware like threadfin/xTeVe and Plex DVR to consume livestreams as if they were standard HTTP video streams.

## How It Works

When a client makes an HTTP request, LiveProxy parses the URL to determine which tool and stream URL to use, invokes the appropriate extractor, and pipes the raw video data back as the HTTP response body. The stream stays open for as long as the source is live and the client is connected.

```
Client (VLC / threadfin / Kodi)
  |
  |  GET http://host:53422/cmd/streamlink https://youtube.com/... best/
  v
LiveProxy (HTTP server, port 53422)
  |
  |  Invokes streamlink / yt-dlp / youtube-dl
  v
Stream extractor fetches video from source
  |
  |  Pipes raw video data back
  v
Client receives continuous HTTP video stream
```

### Bundled Tools

| Tool                                                 | Description                                                           |
| ---------------------------------------------------- | --------------------------------------------------------------------- |
| [Streamlink](https://streamlink.github.io/)          | Extracts streams from livestreaming sites (YouTube, Twitch, etc.)     |
| [yt-dlp](https://github.com/yt-dlp/yt-dlp)           | General-purpose video/stream downloader supporting thousands of sites |
| [youtube-dl](https://github.com/ytdl-org/youtube-dl) | Legacy video downloader, kept for compatibility                       |
| ffmpeg                                               | Video processing, used internally by streamlink/yt-dlp when needed    |

## Quick Start

### Docker Run

```bash
docker run -d --name liveproxy -p 53422:53422 sparticuz/liveproxy:latest
```

### Docker Compose

```yaml
services:
  liveproxy:
    image: sparticuz/liveproxy:latest
    container_name: liveproxy
    ports:
      - 53422:53422
    restart: unless-stopped
```

## Usage

LiveProxy supports two URL patterns for specifying commands.

### `/cmd/` -- Plain Text Commands

Pass the command and arguments directly in the URL path:

```
http://<host>:53422/cmd/<command> <url> [options]/
```

**Examples:**

```bash
# Stream using streamlink
curl http://127.0.0.1:53422/cmd/streamlink%20https://www.youtube.com/user/france24/live%20best/

# Stream using yt-dlp
curl http://127.0.0.1:53422/cmd/yt-dlp%20https://www.youtube.com/user/france24/live/

# Open directly in VLC
vlc http://127.0.0.1:53422/cmd/streamlink%20https://www.twitch.tv/shroud%20best/
```

### `/base64/` -- Base64-Encoded Commands

Encode the full command as base64. This is useful when the command contains special characters that are difficult to URL-encode:

```bash
# Encode: "streamlink https://www.youtube.com/user/france24/live best"
echo -n "streamlink https://www.youtube.com/user/france24/live best" | base64
# Output: c3RyZWFtbGluayBodHRwczovL3d3dy55b3V0dWJlLmNvbS91c2VyL2ZyYW5jZTI0L2xpdmUgYmVzdA==

# Use the encoded string in the URL
curl http://127.0.0.1:53422/base64/c3RyZWFtbGluayBodHRwczovL3d3dy55b3V0dWJlLmNvbS91c2VyL2ZyYW5jZTI0L2xpdmUgYmVzdA==/
```

**More base64 examples:**

```bash
# yt-dlp (encode: "yt-dlp https://www.youtube.com/user/france24/live")
curl http://127.0.0.1:53422/base64/eXQtZGxwIGh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3VzZXIvZnJhbmNlMjQvbGl2ZQ==/

# Open in VLC
vlc http://127.0.0.1:53422/base64/c3RyZWFtbGluayBodHRwczovL3d3dy50d2l0Y2gudHYvc2hyb3VkIGJlc3Q=/
```

### M3U Playlists

You can create M3U playlists with LiveProxy URLs for use with IPTV tools like xTeVe, Plex, or any M3U-compatible player:

```m3u
#EXTM3U
#EXTINF:-1 group-title="News",France 24 (Streamlink)
http://127.0.0.1:53422/base64/c3RyZWFtbGluayBodHRwczovL3d3dy55b3V0dWJlLmNvbS91c2VyL2ZyYW5jZTI0L2xpdmUgYmVzdA==/
#EXTINF:-1 group-title="News",France 24 (yt-dlp)
http://127.0.0.1:53422/base64/eXQtZGxwIGh0dHBzOi8vd3d3LnlvdXR1YmUuY29tL3VzZXIvZnJhbmNlMjQvbGl2ZQ==/
```

## Configuration

### Port

The default port is `53422`. Override it by passing `--port` as a command argument:

```bash
docker run -d -p 12345:12345 sparticuz/liveproxy:latest --port 12345
```

Or in docker-compose:

```yaml
services:
  liveproxy:
    image: sparticuz/liveproxy:latest
    command: ["--port", "12345"]
    ports:
      - 12345:12345
```

### Custom Streamlink Plugins

Mount a volume to add custom Streamlink plugins:

```bash
docker run -d -p 53422:53422 \
  -v /path/to/plugins:/home/liveproxy/.config/streamlink/plugins \
  sparticuz/liveproxy:latest
```

## Details

- **Image:** `sparticuz/liveproxy:latest`
- **Architectures:** `linux/amd64`, `linux/arm64`
- **Base:** `python:3-alpine`
- **Runs as:** Non-root user (`liveproxy`)
- **Default port:** `53422`

## Links

- [LiveProxy](https://github.com/back-to/liveproxy) -- Upstream project
- [Streamlink](https://streamlink.github.io/)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
