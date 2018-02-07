IMAGE_NAME="drake-debbuilder:latest"

docker build . -t ${IMAGE_NAME} 
docker run -e TERM=xterm-256color \
    -v /dev/log:/dev/log:ro \
    -v /run/log:/run/log:ro \
    --tty \
    --rm \
    ${IMAGE_NAME} \
    bin/bash -e builder/release-new-snapshot.bash
