#!/bin/bash

# 默认版本ID
DEFAULT_VERSION_ID="68583f69003922d93cad"

# 检查是否提供了版本参数，如果没有则使用默认值
if [ $# -eq 0 ]; then
    VERSION_ID=$DEFAULT_VERSION_ID
    echo "未提供版本参数，使用默认版本: ${VERSION_ID}"
else
    VERSION_ID=$1
fi

IMAGE_NAME="comfy-plugin"
DOCKER_USERNAME="1018998632"

# 构建镜像
echo "开始构建镜像，版本: ${VERSION_ID}..."
docker build --build-arg version_id=${VERSION_ID} -t ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION_ID} -f comfy-plugin.dockerfile .

echo "镜像构建完成: ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION_ID}"

docker push ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION_ID}
echo "镜像地址: https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}/tags"