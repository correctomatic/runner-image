#!/bin/sh

echo "Starting the Node.js process..."
echo $PROCESS
echo "-----------------"

# Start your Node.js process
case $PROCESS in
  "starter")
    echo "Starting the starter process..."
    exec node src/correction_starter.js
    ;;
  "completer")
    echo "Starting the completer process..."
    exec node src/correction_completer.js
    ;;
  "notifier")
    echo "Starting the notifier process..."
    exec node src/correction_notifier.js
    ;;
  *)
    echo "Unknown process type: $1. Please use 'starter', 'completer' or 'notifier'"
    exit 1
    ;;
esac
