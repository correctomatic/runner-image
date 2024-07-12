ARG NODE_VERSION=20.12.2
FROM node:${NODE_VERSION}-alpine

ARG DOCKER_VERSION=20.10.1
ARG REPO_URL=https://github.com/correctomatic/correction-runner.git
ARG REPO_BRANCH=master

ENV NODE_ENV=production
ENV REDIS_HOST=redis
ENV REDIS_PORT=6379
ENV LOG_LEVEL=info
ENV LOG_FILE=/var/log/correctomatic/correctomatic.log
ENV CONCURRENT_NOTIFIERS=10

# Shared folder between containers
ARG SHARED_FOLDER

# Download and install Docker client binary
RUN apk add --no-cache git curl
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz | tar xz -C /tmp && \
    mv /tmp/docker/docker /usr/local/bin/docker && \
    rm -rf /tmp/docker

# For debugging purposes
RUN apk add curl vim \
    && rm -rf /var/cache/apk/*

USER node

# Shared folder between containers
# RUN mkdir -p ${SHARED_FOLDER}

# App directory
RUN mkdir -p /home/node/app
WORKDIR /home/node/app

# Clone the repo and install dependencies
RUN git clone -b $REPO_BRANCH $REPO_URL correction-runner
WORKDIR /home/node/app/correction-runner
RUN npm install --only=production

# Create log folder
RUN mkdir -p /var/log/correctomatic && chown -R node:node /var/log/correctomatic

# Run the corresponding correctomatic service
COPY --chown=node:node entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

