#!/bin/bash
set -ex 
image=`docker images | awk '{print $1}' | awk 'NR==2'`
encrypted_execution_dir="/usr/local/bin/encrypted-execution"
container="test-build"
git_root=`git rev-parse --show-toplevel`
trap "docker stop $container" EXIT 
echo $image

echo "Pulling test image..."
echo "Running image"
docker run --rm --name "$container" -tid "$image:$git_root" bash
docker exec -w $encrypted_execution_dir $container $encrypted_execution_dir/build-scrambled.sh
echo "copying test"
docker cp $git_root/encrypted-execution/tools/test/ $container:$encrypted_execution_dir
echo "exec build"
docker exec -w $encrypted_execution_dir $container ./test/test-site.sh
