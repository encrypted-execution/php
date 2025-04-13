#!/bin/sh
# Copyright (c) 2020 Polyverse Corporation

image="ghcr.io/encrypted-execution/php-encrypted-execution-builder"
headsha=$(git rev-parse --verify HEAD)

docker run -it $image:$headsha bash
