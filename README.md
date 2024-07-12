# Runner image

Docker image for running the correctomatic processes: starter, completer and notifier. It's the same image for the three processes.

## Using the image

You will probably need to pass some environment variables to the container. You can do it with the `-e` option. The variables you can pass are:

- `PROCESS`: One of the three processes: `starter`, `completer` or `notifier`. This environment variable is mandatory.
- `REDIS_HOST`: Host of the redis server, from the container's point of view.
- `REDIS_PORT`: Port of the redis server
- `REDIS_PASSWORD`: Password for the redis server
- `LOG_LEVEL`: Log level for the application.
- `LOG_FILE`: File where the logs will be written. The path is from the container's point of view.
- `CONCURRENT_NOTIFIERS`: Number of concurrent jobs sending notifications of completed tasks. Defaults to 10
- `DONT_START_CONTAINER`: If set to S, the containers will not start. This is for debugging the completer.

You have the default values in the Dockerfile.

Here is an example of how to run the container with all the environment variables, remove the ones you don't need:
```bash
docker run --rm \
  -e PROCESS=starter \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  -e REDIS_PASSWORD=value \
  -e NODE_ENV=value \
  -e LOG_LEVEL=info \
  -e LOG_FILE=/var/log/correctomatic/correctomatic.log \
  -e CONCURRENT_NOTIFIERS=10 \
  correctomatic/runner
```

## Build the image

TO-DO

Configure modifying .env

Build the image with `./build.sh`


