#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation
set -e

image="encrypted-execution/php-encrypted-execution-builder"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)

docker build -t $image:$headsha .

docker tag $image:$headsha $image:latest
if [[ "$1" == "-g" ]]; then
	echo "Pushing to Github Container Repository"
	docker tag $image:$headsha ghcr.io/$image:$headsha
	docker tag $image:$headsha ghcr.io/$image:latest
	docker push ghcr.io/$image:$headsha
	docker push ghcr.io/$image:latest
fi
