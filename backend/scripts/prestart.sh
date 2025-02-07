#! /usr/bin/env bash

set -e
set -x

# 这行命令会执行 app/backend_pre_start.py 脚本，通常它用于在数据库或其他服务启动时进行必要的前期操作。例如，它可能会初始化数据库连接、检查数据库是否可用、执行一些启动任务等。
python app/backend_pre_start.py

# 此命令通过 Alembic 进行数据库迁移。Alembic 是一个用于管理数据库版本控制的工具。upgrade head 命令会将数据库迁移到最新的版本。
alembic upgrade head

# 这行命令会执行 app/initial_data.py 脚本，通常用于向数据库插入一些初始数据，比如默认的用户、角色、配置设置等。
python app/initial_data.py
