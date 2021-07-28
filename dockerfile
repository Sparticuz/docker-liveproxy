ARG ALPINE_IMAGE=python:3-alpine

FROM ${ALPINE_IMAGE} as build

# Install build dependencies
RUN apk --no-cache add \
    gcc \
    musl-dev

RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Build packages
RUN pip install --user --no-cache-dir --no-warn-script-location liveproxy streamlink youtube-dl

# Create Liveproxy container
FROM ${ALPINE_IMAGE} as liveproxy

# Install ffmpeg for youtube-dl
RUN apk --no-cache add ffmpeg

RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Move liveproxy, streamlink, and youtube-dl from the build image
COPY --from=build /home/liveproxy/.local /home/liveproxy/.local
RUN mkdir -p /home/liveproxy/.config/streamlink/plugins
ENV PATH=$PATH:/home/liveproxy/.local/bin

EXPOSE 53422

ENTRYPOINT [ "liveproxy", "--host", "0.0.0.0" ]
