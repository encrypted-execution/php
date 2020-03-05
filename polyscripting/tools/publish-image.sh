#!/bin/sh

type="$(basename $PWD)"
build="$(basename $(dirname $PWD))"
php_ver="$(basename $(dirname $(dirname $PWD)))"

image="polyverse/ps-php${php_ver}-${build}-${type}"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:$headsha .
docker push $image:$headsha


if [[ "$1" == "-p" ]]; then
    echo "Pushing as latest tag..."
    docker tag $image:$headsha $image:latest
    docker push $image:latest
fi