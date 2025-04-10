FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/python:3.9-slim

WORKDIR /app

# 使用国内镜像源
# RUN #echo "deb https://mirrors.aliyun.com/debian/ bullseye main contrib non-free" > /etc/apt/sources.list.d/aliyun.list \
#    && echo "deb https://mirrors.aliyun.com/debian/ bullseye-updates main contrib non-free" >> /etc/apt/sources.list.d/aliyun.list \
#    && echo "deb https://mirrors.aliyun.com/debian-security bullseye-security main contrib non-free" >> /etc/apt/sources.list.d/aliyun.list

RUN echo "">/etc/sources.list \
    && echo "deb http://mirrors.ustc.edu.cn/debian/ buster main">>/etc/sources.list \
    && echo "deb http://mirrors.ustc.edu.cn/debian/deb:ian-security buster/updates main">>/etc/sources.list \
    && echo "deb http://mirrors.ustc.edu.cn/debian/deb:ian buster-updates main">>/etc/sources.list


# 安装Node.js作为JavaScript运行时（使用国内源）
RUN apt-get update && apt-get install -y \
    curl \
    && curl -sL https://registry.npmmirror.com/-/binary/node/v14.21.3/node-v14.21.3-linux-x64.tar.gz | tar xz -C /usr/local --strip-components=1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 安装依赖
COPY requirements.txt .

RUN pip config set global.index-url http://mirrors.cloud.tencent.com/pypi/simple && \
     pip config set global.trusted-host mirrors.cloud.tencent.com


RUN pip install --no-cache-dir -r requirements.txt

# 复制项目文件
COPY . .

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV WERKZEUG_DEBUG_PIN=off

# 暴露端口
EXPOSE 8081

# 启动应用
CMD ["python", "app.py"]
