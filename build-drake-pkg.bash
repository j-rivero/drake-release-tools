IMAGE_NAME="drake-debbuilder:latest"

mkdir -p drake-pkgs

docker build . -t ${IMAGE_NAME} 
docker run -e TERM=xterm-256color \
    -v /dev/log:/dev/log:ro \
    -v /run/log:/run/log:ro \
    -v ${PWD}/drake-pkgs:/pkgs \
    --tty \
    --rm \
    ${IMAGE_NAME} \
    bin/bash -e builder/release-new-snapshot.bash