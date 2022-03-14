ARG ALPINE_IMAGE=python:3-alpine3.15

FROM ${ALPINE_IMAGE} as build

# Install build dependencies
RUN apk --no-cache add gcc musl-dev libxml2-dev libxslt-dev
RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Build packages
RUN pip install --user --no-cache-dir --no-warn-script-location 'liveproxy==2.0.0' 'streamlink==3.2.0' youtube-dl

# Create Liveproxy container
FROM ${ALPINE_IMAGE} as liveproxy

# Install binary dependencies
RUN apk --no-cache add ffmpeg libxml2 libxslt
RUN addgroup -S liveproxy && adduser -S liveproxy -G liveproxy
USER liveproxy

# Move liveproxy, streamlink, and youtube-dl from the build image
COPY --from=build /home/liveproxy/.local /home/liveproxy/.local
RUN mkdir -p /home/liveproxy/.config/streamlink/plugins
ENV PATH=$PATH:/home/liveproxy/.local/bin

EXPOSE 53422

ENTRYPOINT [ "liveproxy", "--host", "0.0.0.0" ]
