# Stage 0, "build-stage", based on Node.js, to build and compile the frontend
# 第一阶段：使用 Node.js 20 作为基础镜像，并命名这个阶段为 build-stage。
FROM crpi-iay62pbhw1a58p10.cn-hangzhou.personal.cr.aliyuncs.com/visage-namespace/node:20 AS build-stage

# 设置容器内的工作目录为 /app。
WORKDIR /app

# 将 package.json 和 package-lock.json 复制到容器内的 /app/ 目录。
COPY package*.json /app/

# 根据 package.json 安装前端项目依赖。
RUN npm install

# 将项目的所有文件复制到容器的 /app/ 目录中。
COPY ./ /app/

# 使用构建参数 VITE_API_URL，便于动态配置 API 地址。
ARG VITE_API_URL=${VITE_API_URL}

# 执行打包命令，生成生产环境的静态文件，通常会输出到 dist/ 目录。
RUN npm run build


# Stage 1, based on Nginx, to have only the compiled app, ready for production with Nginx
# 第二阶段：使用官方 nginx 镜像作为基础镜像，用于提供静态文件服务。
FROM crpi-iay62pbhw1a58p10.cn-hangzhou.personal.cr.aliyuncs.com/visage-namespace/nginx

# 将第一阶段 build-stage 中生成的静态文件复制到 nginx 镜像中的 /usr/share/nginx/html 目录中，用于提供静态文件服务。
COPY --from=build-stage /app/dist/ /usr/share/nginx/html
# 将自定义的 Nginx 配置文件复制到 Nginx 的配置目录，覆盖默认配置。
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
# 复制一个额外的 Nginx 配置文件（通常用于处理后端返回 404 时的逻辑）。
COPY ./nginx-backend-not-found.conf /etc/nginx/extra-conf.d/backend-not-found.conf
