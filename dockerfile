ARG ALPINE_IMAGE=python:3-alpine3.15

FROM ${ALPINE_IMAGE} as build

# Install build dependencies
RUN apk --no-cache add curl gcc git libxml2-dev libxslt-dev musl-dev

# Install the latest youtube-dl and yt-dlp
RUN curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
RUN chmod a+rx /usr/local/bin/youtube-dl
RUN curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o /usr/local/bin/yt-dlp
RUN chmod a+rx /usr/local/bin/yt-dlp

# Add liveproxy user for building
RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Build streamlink and liveproxy
RUN pip install --user --no-cache-dir --no-warn-script-location 'streamlink==3.2.0' && \
  pip install --user --no-cache-dir --no-warn-script-location git+https://github.com/back-to/liveproxy.git@4124fd8

# Create Liveproxy container
FROM ${ALPINE_IMAGE} as liveproxy

# Install binary dependencies
RUN apk --no-cache add ffmpeg libxml2 libxslt

# Add liveproxy user
RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Move liveproxy, streamlink, youtube-dl, and yt-dlp from the build image
COPY --from=build /home/liveproxy/.local /home/liveproxy/.local
COPY --from=build /usr/local/bin/youtube-dl /usr/local/bin/youtube-dl
COPY --from=build /usr/local/bin/yt-dlp /usr/local/bin/yt-dlp
RUN mkdir -p /home/liveproxy/.config/streamlink/plugins
ENV PATH=$PATH:/home/liveproxy/.local/bin

EXPOSE 53422

ENTRYPOINT [ "liveproxy", "--host", "0.0.0.0" ]
