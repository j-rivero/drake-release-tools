#!/bin/bash -ex

IMAGE_NAME="drake-debbuilder:latest"

mkdir -p drake-pkgs

# The no-cache option could potentially be removed after
# the development
docker build . --no-cache -t ${IMAGE_NAME}
docker run -e TERM=xterm-256color \
    -e MAKE_JOBS \
    -v /dev/log:/dev/log:ro \
    -v /run/log:/run/log:ro \
    -v ${PWD}/drake-pkgs:/pkgs:rw \
    --tty \
    --rm \
    ${IMAGE_NAME} \
    bin/bash -ex builder/release-new-snapshot.bash
