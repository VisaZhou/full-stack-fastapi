# 基础镜像：使用官方的 python:3.10 作为基础镜像，确保使用 Python 3.10 版本
FROM crpi-iay62pbhw1a58p10.cn-hangzhou.personal.cr.aliyuncs.com/visage-namespace/python:3.10


# 设置环境变量：设置 PYTHONUNBUFFERED=1，确保 Python 输出不会被缓冲，便于实时查看日志。
ENV PYTHONUNBUFFERED=1

# 设置工作目录：容器内的工作目录设置为 /app/，后续操作都会基于该目录进行。
WORKDIR /app/

# Install uv
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#installing-uv
# 安装 uv 工具：从 ghcr.io/astral-sh/uv:0.5.11 镜像中复制 uv 工具和 uvx 可执行文件到容器的 /bin/ 目录，使其可以直接运行。
COPY --from=ghcr.io/astral-sh/uv:0.5.11 /uv /uvx /bin/

# Place executables in the environment at the front of the path
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#using-the-environment
# 配置环境变量以设置路径：将 /app/.venv/bin 添加到 PATH 环境变量中，使虚拟环境中的可执行文件可以直接运行。
ENV PATH="/app/.venv/bin:$PATH"

# Compile bytecode
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#compiling-bytecode
# 设置环境变量 UV_COMPILE_BYTECODE=1，确保 uv 在安装依赖时会编译字节码，提高运行时的性能。
ENV UV_COMPILE_BYTECODE=1

# uv Cache
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#caching
# 设置环境变量 UV_CACHE=1，确保 uv 会缓存依赖，提高构建速度。
ENV UV_LINK_MODE=copy

# Install dependencies
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#intermediate-layers
# 安装依赖：
#	--mount=type=cache,target=/root/.cache/uv：缓存 uv 工具使用的文件。
#	--mount=type=bind,source=uv.lock,target=uv.lock 和 pyproject.toml 绑定到容器内，确保一致的依赖版本。
#	--frozen：确保依赖不会发生变化。
#	--no-install-project：仅同步依赖，不安装项目自身。
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project

# 将 /app 添加到 PYTHONPATH，确保项目的模块可以被正确导入。    
ENV PYTHONPATH=/app

# 将项目的脚本、配置文件和应用代码复制到容器的 /app 目录中。
COPY ./scripts /app/scripts

COPY ./pyproject.toml ./uv.lock ./alembic.ini /app/

COPY ./app /app/app

# Sync the project
# Ref: https://docs.astral.sh/uv/guides/integration/docker/#intermediate-layers
# 再次运行 uv sync，确保项目及依赖完整同步，避免遗漏。
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync

# 使用 fastapi 命令启动应用，指定 4 个 worker 运行 app/main.py 文件。
CMD ["fastapi", "run", "--workers", "4", "app/main.py"]
