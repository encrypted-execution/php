#!/bin/bash

cd encrypted-execution
./build.sh

cd ../8.4/bookworm/apache
./publish-image.sh

image="encrypted-execution/ee-php8.4-apache"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)

cd ../../..
docker run --rm -it -v $PWD/ee:/ee $image:$headsha bash
