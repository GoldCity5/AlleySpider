#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File    :   app.py
@Time    :   2025年04月09日
@Desc    :   抖音爬虫Flask服务
'''
import logging
import os
import traceback
import sys

from cookies import cookies_str_to_dict, save_cookie

# 禁用Werkzeug调试PIN
os.environ['WERKZEUG_DEBUG_PIN'] = 'off'

# 配置日志
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s [%(levelname)s] %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

from flask import Flask, jsonify, request
from douyin import Douyin

app = Flask(__name__)

@app.route('/getDouyinUserInfo', methods=['GET'])
def get_douyin_user_info():
    """获取抖音用户信息接口"""
    url = request.args.get('url', '')
    limit = request.args.get('limit', 10, type=int)
    
    logger.info(f"接收到请求: getDouyinUserInfo, url={url}, limit={limit}")
    
    if not url:
        logger.warning("请求缺少url参数")
        return jsonify({"error": "请提供抖音链接"}), 400
    
    try:
        douyin = Douyin(url, limit=limit)
        douyin.run_get_user_info()
        logger.info(f"成功获取用户信息: {douyin.info.get('nickname', '')}")
        return jsonify(douyin.info)
    except Exception as e:
        error_msg = str(e)
        stack_trace = traceback.format_exc()
        logger.error(f"获取用户信息失败: {error_msg}\n{stack_trace}")
        return jsonify({"error": error_msg}), 500

@app.route('/getDouyinVideoList', methods=['GET'])
def get_douyin_video_list():
    """获取抖音视频列表接口"""
    url = request.args.get('url', '')
    limit = request.args.get('limit', 10, type=int)
    
    logger.info(f"接收到请求: getDouyinVideoList, url={url}, limit={limit}")
    
    if not url:
        logger.warning("请求缺少url参数")
        return jsonify({"error": "请提供抖音链接"}), 400
    
    try:
        douyin = Douyin(url, limit=limit)
        douyin.run()
        logger.info(f"成功获取视频列表: 共{len(douyin.results)}条结果")
        return jsonify(douyin.results)
    except Exception as e:
        error_msg = str(e)
        stack_trace = traceback.format_exc()
        logger.error(f"获取视频列表失败: {error_msg}\n{stack_trace}")
        return jsonify({"error": error_msg}), 500


@app.route('/setCookie', methods=['GET'])
def set_douyin_cookie():
    """设置抖音cookie"""
    cookie = request.args.get('cookie', '')

    logger.info(f"接收到请求: setCookie, cookie长度={len(cookie)}")

    if not cookie:
        logger.warning("请求缺少cookie参数")
        return jsonify({"error": "请提供正确的cookie"}), 400

    try:
        cookie = cookies_str_to_dict(cookie)
        save_cookie(cookie)
        logger.info("cookie设置成功")
        return jsonify({"message": "cookie设置成功"})
    except Exception as e:
        error_msg = str(e)
        stack_trace = traceback.format_exc()
        logger.error(f"cookie设置失败: {error_msg}\n{stack_trace}")
        return jsonify({"error": error_msg}), 500



if __name__ == '__main__':
    logger.info("=== 抖音爬虫Flask服务正在启动 ===")
    logger.info("API接口列表:")
    logger.info("1. /getDouyinUserInfo - 获取抖音用户信息")
    logger.info("2. /getDouyinVideoList - 获取抖音视频列表")
    logger.info("3. /setCookie - 设置抖音cookie")
    logger.info("=== 服务器地址: http://0.0.0.0:8081 ===\n")
    
    try:
        app.run(host='0.0.0.0', port=8081, debug=True)
    except Exception as e:
        logger.error(f"服务启动失败: {str(e)}\n{traceback.format_exc()}")
