#! /usr/bin/env bash

# Read .env file
export $(grep -v '^#' .env | xargs)

docker build \
    --build-arg REPO_URL=$REPO_URL \
    --build-arg REPO_BRANCH=$REPO_BRANCH \
    --build-arg DOCKER_VERSION=$DOCKER_VERSION \
    --tag $DOCKERHUB_USER/$IMAGE_NAME:$IMAGE_TAG \
    --tag $DOCKERHUB_USER/$IMAGE_NAME:latest \
    "$@" \
    .
