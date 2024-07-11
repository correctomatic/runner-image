FROM node:20.12.2-alpine
# Shared folder between containers
ARG SHARED_FOLDER


ARG DOCKER_VERSION
ARG REPO_URL
ARG REPO_BRANCH

ENV DOCKER_VERSION=${DOCKER_VERSION}
ENV REPO_URL=${REPO_URL}
ENV REPO_BRANCH=${REPO_BRANCH}

# ¿?
ENV SECRET_KEY=${SECRET_KEY}

# Download and install Docker client binary
RUN apk add --no-cache git curl
RUN curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar xz -C /tmp && \
    mv /tmp/docker/docker /usr/local/bin/docker && \
    rm -rf /tmp/docker

# Give the node user access to the Docker socket on the host
# This will create a group with the same ID as the Docker group on the host
# and add the node user to that group. If the group already exists, it will
# just add the user to the group.
# RUN if ! getent group ${DOCKER_GROUP_ID} >/dev/null; then \
# addgroup -g ${DOCKER_GROUP_ID} docker; \
# fi && \
# adduser node `getent group ${DOCKER_GROUP_ID} | cut -d: -f1`


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
RUN npm install

# Delayed start, to allow the Redis container to initialize
# COPY --chown=node:node delayed_start.sh /
# RUN chmod +x /delayed_start.sh
# ENV DELAY_SECONDS=${DELAY_SECONDS}
