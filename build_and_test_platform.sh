#!/bin/bash
# Inspired by https://github.com/sensu/sensu-ruby-runtime/blob/main/build_and_test_platform.sh

ignore_errors=0
node_version=16.19.1
asset_version=${TAG:-local-build}
asset_filename=sensu-nodejs-runtime_${asset_version}_nodejs-${node_version}_${platform}_linux_amd64.tar.gz
asset_image=sensu-nodejs-runtime-${node_version}-${platform}:${asset_version}


if [ "${asset_version}" = "local-build" ]; then
  echo "Local build"
  ignore_errors=1
fi

echo "Platform: ${platform}"
echo "Check for asset file: ${asset_filename}"
if [ -f "$PWD/dist/${asset_filename}" ]; then
  echo "File: "$PWD/dist/${asset_filename}" already exists!!!"
  [ $ignore_errors -eq 0 ] && exit 1
else
  echo "Check for docker image: ${asset_image}"
  if [[ "$(docker images -q ${asset_image} 2> /dev/null)" == "" ]]; then
    echo "Docker image not found...we can build"
    echo "Building Docker Image: sensu-nodejs-runtime:${node_version}-${platform}"
    docker build --build-arg "NODE_VERSION=$node_version" --build-arg "ASSET_VERSION=$asset_version" -t ${asset_image} -f Dockerfile.${platform} .
    echo "Making Asset: /assets/sensu-nodejs-runtime_${asset_version}_nodejs-${node_version}_${platform}_linux_amd64.tar.gz"
    docker run --rm -v "$PWD/dist:/dist" ${asset_image} cp /assets/${asset_filename} /dist/
  #    #rm $PWD/test/*
  #    #cp $PWD/dist/${asset_filename} $PWD/dist/${asset_filename}
  else
    echo "Image already exists!!!"
    [ $ignore_errors -eq 0 ] && exit 1
  fi
fi


test_arr=($test_platforms)
for test_platform in "${test_arr[@]}"; do
  echo "Test: ${test_platform}"
  docker run --rm -e platform -e test_platform=${test_platform} -e asset_filename=${asset_filename} -v "$PWD/scripts/:/scripts" -v "$PWD/dist:/dist" ${test_platform} /scripts/test.sh
  retval=$?
  if [ $retval -ne 0 ]; then
    echo "!!! Error testing ${asset_filename} on ${test_platform}"
    exit $retval
  fi
done