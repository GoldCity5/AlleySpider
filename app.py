#!/usr/bin/env python
# -*- encoding: utf-8 -*-
'''
@File    :   app.py
@Time    :   2025年04月09日
@Desc    :   抖音爬虫Flask服务
'''

import os

from cookies import cookies_str_to_dict, save_cookie

# 禁用Werkzeug调试PIN
os.environ['WERKZEUG_DEBUG_PIN'] = 'off'

from flask import Flask, jsonify, request
from douyin import Douyin

app = Flask(__name__)

@app.route('/getDouyinUserInfo', methods=['GET'])
def get_douyin_user_info():
    """获取抖音用户信息接口"""
    url = request.args.get('url', '')
    limit = request.args.get('limit', 10, type=int)
    
    if not url:
        return jsonify({"error": "请提供抖音链接"}), 400
    
    try:
        douyin = Douyin(url, limit=limit)
        douyin.run_get_user_info()
        return jsonify(douyin.info)
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/getDouyinVideoList', methods=['GET'])
def get_douyin_video_list():
    """获取抖音视频列表接口"""
    url = request.args.get('url', '')
    limit = request.args.get('limit', 10, type=int)
    
    if not url:
        return jsonify({"error": "请提供抖音链接"}), 400
    
    try:
        douyin = Douyin(url, limit=limit)
        douyin.run()
        return jsonify(douyin.results)
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route('/setCookie', methods=['GET'])
def set_douyin_cookie():
    """设置抖音cookie"""
    cookie = request.args.get('cookie', '')

    if not cookie:
        return jsonify({"error": "请提供正确的cookie"}), 400

    try:
        cookie = cookies_str_to_dict(cookie)
        save_cookie(cookie)
        return jsonify({"message": "cookie设置成功"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081, debug=True)
