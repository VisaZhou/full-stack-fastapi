#!/usr/bin/env bash

set -e
set -x
# 使用 coverage 工具运行 pytest 测试。--source=app 指定计算覆盖率的代码路径为 app 目录。-m pytest 表示运行 pytest 模块。
coverage run --source=app -m pytest -v -s
# 生成覆盖率报告。--show-missing 参数表示显示未覆盖的代码行。
coverage report --show-missing
# 生成 HTML 格式的覆盖率报告。--title 参数指定报告的标题。
coverage html --title "${@-coverage}"
