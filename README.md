# Runner image

Docker image for running the correctomatic processes: starter, completer and notifier. It's the same image for the three processes. The source code for the correctomatic processes is in the [correction-runner](https://github.com/correctomatic/correction-runner) repository.

The image is available in [Docker Hub](https://hub.docker.com/r/correctomatic/runner).

**TO-DO**: configure access to a private registry

## Using the image

There are two ways of configuring the image: with environment variables or with an `.env` file. In both cases, the variables are the same as defined in the correction-runner's [.env-example](https://github.com/correctomatic/correction-runner/blob/master/.env.example) file.


### Using .env file

You can use a `.env` file to configure the container. Mount the file to the container in the `/app` directory:

```bash
docker run --rm \
  -v /path/to/.env:/app/.env \
  correctomatic/runner
```

The documentation for shuch `.env` file is in the [correction-runner repository](https://github.com/correctomatic/correction-runner/blob/master/.env.example), but are the same as the environment variables described below.

### Using environment variables

The main variables you can pass are:

- `PROCESS`: One of the three processes: `starter`, `completer` or `notifier`. This environment variable is mandatory.
- `REDIS_HOST`: Host of the redis server, from the container's point of view.
- `REDIS_PORT`: Port of the redis server
- `REDIS_PASSWORD`: Password for the redis server
- `DOCKER_OPTIONS`: JSON [Dockerode](https://github.com/apocas/dockerode) options for connecting to the docker server. If empty, will connecto to the local docker socket. See below for an example.
- `DOCKER_OPTIONS_FILE`: Path to a file with the docker options. If `DOCKER_OPTIONS` is set, it will be ignored.
- `DOCKER_TIMEOUT`: Timeout for the docker commands
- `DOCKER_PULL`: If set to `true`, the container will pull the images before starting the tasks.
- `DOCKER_PULL_TIMEOUT`: Timeout for the docker pull command.
- `DOCKER_REPOSITORY_CREDENTIALS`: JSON object with the credentials for the docker repository. The key is the repository URL, and the value is an object with the `username` and `password` keys.
- `DOCKER_REPOSITORY_CREDENTIALS_FILE`: Path to a file with the docker repository credentials. If `DOCKER_REPOSITORY_CREDENTIALS` is set, it will be merged with the contents of this file.
- `CONCURRENT_NOTIFIERS`: Number of concurrent jobs sending notifications of completed tasks.

There are also variables for debugging:
- `LOG_LEVEL`: Log level for the application.
- `LOG_FILE`: File where the logs will be written. The path is from the container's point of view.
- `DONT_START_CONTAINER`: If set to S, the containers will not start. This is for debugging the completer.

You have the default values in the Dockerfile.

This is an example of how to run the container to connect to a remote docker server. You will need to mount the certificates in the container, and set the `DOCKER_OPTIONS` environment variable:

```bash
docker run --rm \
  -e PROCESS=starter \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=value \
  -e DOCKER_OPTIONS='{
    "host": "your.docker.host.here",
    "protocol": "https",
    "port": 2376,
    "ca": "/certs/ca.pem",
    "cert": "/certs/cert.pem",
    "key": "/certs/key.pem"
  }' \
  -e DOCKER_TIMEOUT=5000 \
  -e DOCKER_PULL=true \
  -e DOCKER_PULL_TIMEOUT=10000 \
  -e DOCKER_REPOSITORY_CREDENTIALS='{
    "your.docker.registry.here": {
      "username": "your-username",
      "password": "your-password"
    }
  }' \
  -e NODE_ENV=value \
  -e LOG_LEVEL=info \
  -e LOG_FILE=/var/log/correctomatic/correctomatic.log \
  -e CONCURRENT_NOTIFIERS=10 \
  -v /your/local/certs/dir:/certs \
  correctomatic/runner
```

Alternatively, you can use files with the docker options and the repository credentials.

Here is an example of how to run the container with most of the environment variables for connecting to your local docker server. Note that `DOCKER_OPTIONS` is not set, and that it bind mounts the local docker socket:
```bash
docker run --rm \
  -e PROCESS=starter \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=value \
  -e DOCKER_TIMEOUT=5000 \
  -e DOCKER_PULL=true \
  -e DOCKER_PULL_TIMEOUT=10000 \
  -e NODE_ENV=value \
  -e LOG_LEVEL=info \
  -e LOG_FILE=/var/log/correctomatic/correctomatic.log \
  -e CONCURRENT_NOTIFIERS=10 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  correctomatic/runner
```

For that to work, the user running the container must have access to the docker socket. You will need to build the image with the `DOCKER_GROUP_ID` build argument set to the docker group id in the host. For example, if the docker group id in your local machine is 999:

```bash
./build.sh --build-arg DOCKER_GROUP_ID=999
```

## Build the image

Build the image with `./build.sh`. All the parameters passed to the script will be passed to the `docker build` command. For example, to build the image with a custom tag:

```bash
./build.sh --no-cache --tag correctomatic/runner:custom-tag
```

Take in account that some parameters are fixed in the script, like the git repository and the docker version to install in the image, which are defined in the `.env` file in this repository.

