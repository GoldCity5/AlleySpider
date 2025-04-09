#!/bin/bash

# 设置变量
REPO_DIR=~/app/AlleySpider
IMAGE_NAME="douyin-spider"
CONTAINER_NAME="douyin-spider-app"

# 同步代码
cd $REPO_DIR && git pull origin main

# 容器重建
docker stop $CONTAINER_NAME || true
docker rm $CONTAINER_NAME || true
docker build -t $IMAGE_NAME:latest .
docker run -d -p 8081:8081 --name $CONTAINER_NAME $IMAGE_NAME:latest

# 显示容器状态
docker ps | grep $CONTAINER_NAME
