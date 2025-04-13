#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation

PHP_VERSION=8.4

image="ghcr.io/encrypted-execution/php-${PHP_VERSION}-${BUILD_TYPE}-apache-debian"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:$headsha .
echo "Pushing with commit tag..."
docker push $image:$headsha

if [[ "$1" == "-g" ]]; then

    echo "Pushing as latest tag..."
    docker tag $image:$headsha $image:latest
    docker push $image:latest
fi
