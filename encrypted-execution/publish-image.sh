#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation
set -e

image="ghcr.io/encrypted-execution/php-encrypted-execution-builder"

echo "$(date) Obtaining current git sha for tagging the docker image"
if [[ "$headsha" == "" ]]; then
	headsha=$(git rev-parse --verify HEAD)
fi

docker build -t $image:$headsha .

docker tag $image:$headsha $image:latest
if [[ "$1" == "-p" ]]; then
	echo "Pushing to Github Container Repository"
	docker tag $image:$headsha ghcr.io/$image:$headsha
	docker tag $image:$headsha ghcr.io/$image:latest
	docker push ghcr.io/$image:$headsha
	docker push ghcr.io/$image:latest
fi
