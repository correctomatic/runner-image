ARG NODE_VERSION=20.12.2
FROM node:${NODE_VERSION}-alpine

ARG DOCKER_VERSION=20.10.1
ARG REPO_URL=https://github.com/correctomatic/correction-runner.git
ARG REPO_BRANCH=master
ARG DOCKER_GROUP_ID=999
ARG CERTS_DIR=/certs

ENV NODE_ENV=production
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV DOCKER_OPTIONS=""
ENV DOCKER_TIMEOUT=2000
ENV LOG_LEVEL=info
ENV LOG_FILE=/var/log/correctomatic/correctomatic.log
ENV CONCURRENT_NOTIFIERS=10

# Download and install Docker client binary
RUN apk add --no-cache git curl
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz | tar xz -C /tmp && \
    mv /tmp/docker/docker /usr/local/bin/docker && \
    rm -rf /tmp/docker


# Give the node user access to the Docker socket on the host
# This will create a group with the same ID as the Docker group on the host
# and add the node user to that group. If the group already exists, it will
# just add the user to the group.
RUN if [ -n "${DOCKER_GROUP_ID}" ]; then \
    if ! getent group ${DOCKER_GROUP_ID} >/dev/null; then \
        addgroup -g ${DOCKER_GROUP_ID} docker; \
    fi && \
    adduser node `getent group ${DOCKER_GROUP_ID} | cut -d: -f1`; \
fi

# Create log folder
RUN mkdir -p /var/log/correctomatic && chown -R node:node /var/log/correctomatic

# App directory
RUN mkdir -p /app && chown -R node:node /app

USER node
WORKDIR /app

# Clone the repo and install dependencies
RUN git clone -b $REPO_BRANCH $REPO_URL .
RUN npm install --omit=dev

# Run the corresponding correctomatic service
COPY --chown=node:node entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

