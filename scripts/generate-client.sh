#! /usr/bin/env bash
# 启用“错误退出”模式。如果任何命令失败（返回非零状态），脚本会立即终止。
set -e
# 启用“调试模式”。脚本会打印每一行执行的命令及其输出，便于调试。
set -x

cd backend
# 使用 Python 执行一段内联代码：
#   导入 app.main 模块。
#   调用 app.main.app.openapi() 生成 OpenAPI 规范（通常是一个 JSON 对象）。
#   app.openapi() 是 FastAPI 框架自带的方法，无需手动定义。
#   使用 json.dumps 将 OpenAPI 规范转换为 JSON 字符串。
#   将生成的 JSON 字符串写入 ../openapi.json 文件（即上一级目录中的 openapi.json 文件）。
python -c "import app.main; import json; print(json.dumps(app.main.app.openapi()))" > ../openapi.json
# 返回上一级目录。
cd ..
# 将 openapi.json 文件移动到 frontend 目录中。
mv openapi.json frontend/
cd frontend
# 运行 npm run generate-client 命令。
#   该命令会根据package.json中scripts中的配置，调用 openapi-ts工具生成客户端代码。
npm run generate-client
#   使用 biome 工具格式化生成的客户端代码。
#   biome 是一个代码格式化工具，类似于 Prettier。
#   --write 选项表示直接修改文件。
#   ./src/client 是生成的客户端代码所在的目录。
npx biome format --write ./src/client
