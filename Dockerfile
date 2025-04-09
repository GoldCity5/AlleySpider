FROM swr.cn-north-4.myhuaweicloud.com/ddn-k8s/docker.io/python:3.9-slim

WORKDIR /app

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
