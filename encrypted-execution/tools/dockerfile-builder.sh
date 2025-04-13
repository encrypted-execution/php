#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation

headsha=$(git rev-parse --verify HEAD)

dockerfile=$1

echo $(basename $1)
if [[ ! $(basename $1) == "Dockerfile" ]]; then
    echo "Must pass dockerfile as argument."
    exit 1
fi

line="FROM ghcr.io/encrypted-execution/php-encrypted-execution-builder:$headsha as builder"
pattern="FROM ghcr.io\/encrypted-execution\/php-encrypted-execution-builder:$headsha as builder"

enable=$(
    cat <<-'Message'

#add encrypted execution
ENV ENCRYPTED_EXECUTION_PATH "/usr/local/bin/encrypted-execution"
ENV PHP_SRC_PATH "/usr/src/php"
WORKDIR $ENCRYPTED_EXECUTION_PATH
COPY --from=builder /encrypted-execution/ ./
Message
)

if grep -qF 'FROM ghcr.io/encrypted-execution/php-encrypted-execution-builder' $dockerfile; then
    if grep -qF "${line}" $dockerfile; then
        echo "dockerfile already enables encrypted execution."
        exit 0
    fi
    echo "Dockerfile already enables encrypted execution. Old sha found. Updating sha."
    sed -i '' -e "s/.*encrypted-execution\/php-encrypted-execution-builder:.*/${pattern}/" $dockerfile
    exit 0
fi

echo "No encryption builder found, adding encrypted-execution to Dockerfile"

flag="COPY docker-php-source \/usr\/local\/bin\/"
echo "FROM ghcr.io/encrypted-execution/php-encrypted-execution-builder:$headsha as builder" >temp.txt
sed "/${flag}/q" $dockerfile >>temp.txt
echo "$enable" >>temp.txt
grep -v -e 'make -j "$(nproc)";' \
    -e 'make clean;' \
    -e 'docker-php-source delete;' \
    -e 'find -type f -name' \
    -e 'apt-get purge -y --auto-remove' \
    <(sed -e 's#make install;#\${ENCRYPTED_EXECUTION_PATH}/encrypted-execution-enable#' \
        <(awk "f;/${flag}/{f=1}" $dockerfile)) >>temp.txt

mv temp.txt $dockerfile
