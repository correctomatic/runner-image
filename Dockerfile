ARG NODE_VERSION=20.12.2
FROM node:${NODE_VERSION}-alpine

ARG DOCKER_VERSION=20.10.1
ARG REPO_URL=https://github.com/correctomatic/correction-runner.git
ARG REPO_BRANCH=master

# Shared folder between containers
ARG SHARED_FOLDER

# ¿?
# ENV SECRET_KEY=${SECRET_KEY}

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

# Delayed start, to allow the Redis container to initialize
# COPY --chown=node:node delayed_start.sh /
# RUN chmod +x /delayed_start.sh
# ENV DELAY_SECONDS=${DELAY_SECONDS}


RUN echo "Oh dang look at that $NODE_VERSION"
