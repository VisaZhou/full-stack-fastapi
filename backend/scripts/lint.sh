#!/usr/bin/env bash
# set -e: 当脚本中的任一命令返回非零退出状态时立即终止执行。
set -e
# set -x: 在执行命令前打印命令及其参数，方便调试。
set -x
# 使用 mypy 对 app 目录中的 Python 代码进行 静态类型检查。
mypy app
#•	使用 ruff 对 app 目录中的代码进行 静态分析。
#•	ruff 是一个快速的 Python linter，功能类似于 flake8 等工具。
#•	它可以检查代码中的语法错误、格式问题、代码复杂度等。
ruff check app
#•	检查 app 目录中的 Python 代码格式是否符合规范。
#•	--check: 只检查而不自动修复格式问题。如果发现不符合规范的代码，会返回非零状态，导致脚本终止。
ruff format app --check
