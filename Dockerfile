FROM alpine:latest AS packager

ARG NODE_VERSION=22.14.0

ENV LINUX_ARCH=linux-x64
ENV WIN_ARCH=win-x64

ENV LINUX_FILENAME=node-v${NODE_VERSION}-${LINUX_ARCH}

# Install prerequisites
RUN apk add --no-cache curl tar gzip zip coreutils

# Create dist and temp directories
RUN mkdir -p /assets /tmp/linux/bin /tmp/windows/bin

# Download and extract Linux nodejs
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/${LINUX_FILENAME}.tar.gz | tar -xz --strip-components=2 -C /tmp/linux/bin ${LINUX_FILENAME}/bin/node

# Download and extract Windows nodejs
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/${WIN_ARCH}/node.exe -o /tmp/windows/bin/node.exe

# Package Linux binary
RUN tar -czvf /assets/sensu-nodejs-runtime_${NODE_VERSION}_node-v${NODE_VERSION}_linux_amd64.tar.gz -C /tmp/linux bin && \
  sha512sum /assets/sensu-nodejs-runtime_${NODE_VERSION}_node-v${NODE_VERSION}_linux_amd64.tar.gz > /assets/sensu-nodejs-runtime_${NODE_VERSION}_sha512-checksums.txt

# Package Windows binary
RUN tar -czvf /assets/sensu-nodejs-runtime_${NODE_VERSION}_node-v${NODE_VERSION}_windows_amd64.tar.gz -C /tmp/windows bin && \
  sha512sum /assets/sensu-nodejs-runtime_${NODE_VERSION}_node-v${NODE_VERSION}_windows_amd64.tar.gz >> /assets/sensu-nodejs-runtime_${NODE_VERSION}_sha512-checksums.txt
