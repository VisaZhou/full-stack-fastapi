#! /usr/bin/env bash
set -e
set -x

# 检测数据库是否已准备好接收连接，通过重试机制确保服务在数据库初始化完成后顺利运行。
python app/tests_pre_start.py
# 使用 coverage 工具运行 pytest 测试. 并生成覆盖率报告
bash scripts/test.sh "$@"
