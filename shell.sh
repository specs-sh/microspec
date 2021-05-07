#! /usr/bin/env bash

which docker &>/dev/null || { echo "Please install Docker to use $0" >&2; exit 1; }

(( $# == 0 )) && { echo "Usage: $0 [BASH version] [command (optional)]

If a command is provided, it will be run in a docker image of the specified BASH version.
If a command is not provided, it will start an interactive BASh session.

For a list of available BASH versions, see the bash Docker image on Docker Hub:
https://hub.docker.com/_/bash
"; exit 0; }

version="$1"
shift

if ! docker images bash --format "{{.Tag}}" | grep "$version" >&2
then
  echo "BASH image not installed locally for version: $version"
  echo
  echo "Pulling image from Docker Hub..."
  docker pull "bash:$version"
  (( $? == 0 )) || { echo "Docker pull failed" >&2; exit 1; }
fi

docker run --rm -it -v "$PWD:/app" -w /app "bash:$version" bash "$@"