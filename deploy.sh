#!/bin/bash
# 抖音爬虫自动部署脚本

# 设置变量
IMAGE_NAME="douyin-spider"
CONTAINER_NAME="douyin-spider-app"
PORT=8081
GIT_REPO="https://github.com/GoldCity5/AlleySpider.git"  # 请替换为你的Git仓库地址
GIT_BRANCH="main"  # 请替换为你的分支名

# 输出彩色文本函数
function echo_color() {
    case $1 in
        "green") echo -e "\033[32m$2\033[0m" ;;
        "red") echo -e "\033[31m$2\033[0m" ;;
        "yellow") echo -e "\033[33m$2\033[0m" ;;
        *) echo "$2" ;;
    esac
}

# 检查是否安装了Docker
if ! command -v docker &> /dev/null; then
    echo_color "red" "Docker未安装，请先安装Docker"
    exit 1
fi

# 创建临时目录
TEMP_DIR=$(mktemp -d)
echo_color "green" "创建临时目录: $TEMP_DIR"

# 清理函数
function cleanup() {
    echo_color "yellow" "清理临时目录..."
    rm -rf "$TEMP_DIR"
    echo_color "green" "清理完成"
}

# 捕获退出信号
trap cleanup EXIT

# 拉取代码
echo_color "green" "正在从Git仓库拉取代码..."
if [ -z "$GIT_REPO" ]; then
    echo_color "yellow" "未设置Git仓库，使用当前目录代码"
    cp -r . "$TEMP_DIR"
else
    git clone -b "$GIT_BRANCH" "$GIT_REPO" "$TEMP_DIR"
    if [ $? -ne 0 ]; then
        echo_color "red" "Git拉取失败"
        exit 1
    fi
fi
echo_color "green" "代码拉取完成"

# 进入临时目录
cd "$TEMP_DIR"

# 构建Docker镜像
echo_color "green" "正在构建Docker镜像: $IMAGE_NAME..."
docker build -t "$IMAGE_NAME" .
if [ $? -ne 0 ]; then
    echo_color "red" "Docker镜像构建失败"
    exit 1
fi
echo_color "green" "Docker镜像构建成功"

# 停止并删除旧容器（如果存在）
if docker ps -a | grep -q "$CONTAINER_NAME"; then
    echo_color "yellow" "停止并删除旧容器..."
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
fi

# 启动新容器
echo_color "green" "正在启动新容器..."
docker run -d --name "$CONTAINER_NAME" \
    -p "$PORT:8081" \
    --restart unless-stopped \
    "$IMAGE_NAME"

if [ $? -ne 0 ]; then
    echo_color "red" "容器启动失败"
    exit 1
fi

# 检查容器是否成功运行
sleep 2
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo_color "green" "容器启动成功！"
    echo_color "green" "服务已在 http://localhost:$PORT 上运行"
else
    echo_color "red" "容器未能成功运行，请检查日志"
    docker logs "$CONTAINER_NAME"
    exit 1
fi

# 显示容器日志
echo_color "yellow" "容器日志:"
docker logs "$CONTAINER_NAME"
