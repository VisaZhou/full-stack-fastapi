## 配置文件运行顺序
### 默认方式
配置文件默认按照docker-compose.yml-->docker-compose.override.yml的顺序合并两个配置文件，后者覆盖前者，并且不会使用docker-compose.traefik.yml文件
### 显式方式
显式地使用按照docker-compose.yml-->docker-compose.override.yml-->docker-compose.traefik.yml的顺序合并三个配置文件，后者覆盖前者
``` bash
docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.traefik.yml watch
docker compose -f docker-compose.yml -f docker-compose.override.yml -f docker-compose.traefik.yml up
```
### 忽略方式
完全忽略docker-compose.override.yml文件，使其不自动覆盖
``` bash
docker compose -f docker-compose.yml watch
docker compose -f docker-compose.yml up
```

### 检查最终合并的命令
``` bash
docker compose config
```

## 运行compose
### watch
	•	不加服务名：启动docker-compose所有服务。
    •	加上服务名：启动指定服务及其依赖的服务，但只监视指定服务。
	•	如果容器尚未创建，会根据服务配置创建新的容器。
	•	如果镜像不存在，会尝试拉取镜像或构建镜像。
	•	自动创建并连接服务到网络，挂载卷等。
	•	需要保持运行状态，以便监视代码或配置的变化，因此不支持-d后台运行。
	•	实时监视代码和配置的变化，并在检测到变化时自动重启受影响的服务,用于开发环境，加快调试过程。
``` bash
docker compose watch 服务名
```

### up
	•	不加服务名：启动docker-compose所有服务。
    •	加上服务名：启动指定服务及其依赖的服务。
    •	如果容器尚未创建，会根据服务配置创建新的容器。
	•	如果镜像不存在，会尝试拉取镜像或构建镜像。
	•	自动创建并连接服务到网络，挂载卷等。
	•	支持 -d 后台运行，不阻塞终端。
	•	适用于生产和稳定运行。
``` bash
docker compose up -d 服务名
```

### start
	•	不加服务名：启动已经停止的所有容器，但不会创建新的容器。
    •	加上服务名：只启动指定容器，不启动依赖容器
	•	不会重新构建或重新应用配置。
	•	适用于已经存在的容器，需要直接启动的情况。
    •	该命令本质上已经是一个后台操作了，不会阻塞终端，不需要且不可以加 -d。
``` bash
docker compose start 服务名
```


## 停止compose
### down
	•	停止并销毁指定服务对应的容器，同时清理与之关联的网络和资源。 
	•	不支持单独服务的停止与销毁。
	•	如果使用了卷，除非显式指定删除（如 --volumes），数据卷通常会保留。
    •	适用于完全移除服务的运行环境，准备重新部署或释放资源。 
``` bash
docker compose down
docker-compose --env-file .env-traefik -f docker-compose.traefik.yml down
```

### stop
	•	容器没有被销毁，可以通过 docker-compose start 服务名称 或 docker start 容器ID 恢复运行。
	•	挂载的卷、网络等资源仍然存在。
	•	常用于短暂停止服务（例如需要暂停服务一段时间）。
``` bash
docker compose stop 服务名
```

## 其他命令
### 查看日志
带 -f 表示实时输出
``` bash
docker compose logs -f 服务名称
```

### 进入容器
``` bash
docker-compose exec 服务名称 /bin/bash
docker-compose --env-file .env-traefik -f docker-compose.traefik.yml exec traefik sh
``` 

### 查看容器
``` bash
docker-compose ps 服务名称
```

### 查看变量渲染后的配置
``` bash
docker-compose --env-file .env-traefik -f docker-compose.traefik.yml config
```

## 数据卷
### 查看指定数据卷
数据卷名称默认使用：项目名_卷名
Mountpoint：指示数据卷在宿主机上的实际存储路径。（mac中为Docker Desktop虚拟机中的路径）
``` bash
docker volume inspect full_stack_fastapi_app-db-data

输出
[
    {
        "CreatedAt": "2025-01-19T10:47:24Z",
        "Driver": "local",
        "Labels": {
            "com.docker.compose.project": "full-stack-fastapi",
            "com.docker.compose.version": "2.31.0",
            "com.docker.compose.volume": "app-db-data"
        },
        "Mountpoint": "/var/lib/docker/volumes/full-stack-fastapi_app-db-data/_data",
        "Name": "full-stack-fastapi_app-db-data",
        "Options": null,
        "Scope": "local"
    }
]
```

### 进入指定数据卷
通过alpine 创建临时挂载卷，可直接访问卷中数据，需要先安装alpine
运行完成后直接就进入了,exit退出
``` bash
docker run --rm -it -v full-stack-fastapi_app-db-data:/data crpi-iay62pbhw1a58p10.cn-hangzhou.personal.cr.aliyuncs.com/visage-namespace/alpine sh
```


### 查看所有数据卷
会有很多随机ID匿名卷，是由于在compose中volume不明确指定名称产生的。例如volume：- /var/lib/postgresql/data/pgdata
``` bash
docker volume ls

输出
DRIVER    VOLUME NAME
local     158e85cb2b2d14de5d9448c4e06268ee2da9db7693675d29afda6b6a87e84865
local     e1ed2a7ed7fe0d9c58fff1feb1d18ebaaa485b0b5e0e2ffca765e012d6c491e8
local     e8ca168adb89b1dd1ddff9ddc353b52310fbe59a7d95b7f7a86190581a862efa
local     full-stack-fastapi_app-db-data
```

### 清理无用数据卷
``` bash
docker volume prune
```

## 过滤容器信息
查询带有 app=web 标签的容器
``` bash
docker ps --filter "label=app=web"
```
## 网络
### 手动创建网络
``` bash
docker network create traefik-public
```

### 删除手动创建的网络
``` bash
docker network rm traefik-public
```

### 查看现有的网络
``` bash
docker network ls

输出
NETWORK ID     NAME                                DRIVER    SCOPE
22354679fcfc   bridge                              bridge    local
ed60afd203a6   full-stack-fastapi_default          bridge    local
0691a09e0bda   full-stack-fastapi_traefik-public   bridge    local
417cfc43b75f   host                                host      local
55504310e8e6   none                                null      local
```

### 检查指定网络
``` bash
docker network inspect full-stack-fastapi_traefik-public

输出
[
    {
        "Name": "full-stack-fastapi_traefik-public",
        "Id": "0691a09e0bda0cd8784180a37cd34bf88a8db2472f970d2777fd8d577bb2c95d",
        "Created": "2025-01-22T09:09:09.186416583Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.19.0.0/16",
                    "Gateway": "172.19.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "19588ee2ef27e0a0fa42397974758609b67707d60adcc957defa7c73dd7afdd9": {
                "Name": "full-stack-fastapi-proxy-1",
                "EndpointID": "5c3d613236e24e79d849fde98ec5228e367919b38ea97584087ec8a1a65eced3",
                "MacAddress": "02:42:ac:13:00:03",
                "IPv4Address": "172.19.0.3/16",
                "IPv6Address": ""
            },
            "202c65746e4366a6df4243ff4147d74433812668054d4ecabc3f75665b9d1529": {
                "Name": "full-stack-fastapi-frontend-1",
                "EndpointID": "a7806eb7456e4947d1b634720f38aa6fa763a9e801eda47b4f6093eb2b50d6e1",
                "MacAddress": "02:42:ac:13:00:02",
                "IPv4Address": "172.19.0.2/16",
                "IPv6Address": ""
            },
            "781c9c854dc045e96040be250781e2a91a81bc6a63557462b3fe677e2918f859": {
                "Name": "full-stack-fastapi-backend-1",
                "EndpointID": "d46745965b4e990a53380a1ca878be26de72cdd94470b8b145756032f695cc77",
                "MacAddress": "02:42:ac:13:00:05",
                "IPv4Address": "172.19.0.5/16",
                "IPv6Address": ""
            },
            "861da18ae4541b97204226b05483bebabda612582d4dda7d6f5c432c1c406f57": {
                "Name": "full-stack-fastapi-adminer-1",
                "EndpointID": "87730f7dff190d03466d5b0007dd24dfb92a63b4b238e69a0d2dbc60546351d6",
                "MacAddress": "02:42:ac:13:00:04",
                "IPv4Address": "172.19.0.4/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.config-hash": "96abfde6e6eea36407de13042220c52a63a75976916465d168dbbf02a3c94a4f",
            "com.docker.compose.network": "traefik-public",
            "com.docker.compose.project": "full-stack-fastapi",
            "com.docker.compose.version": "2.31.0"
        }
    }
]
```









## 停止前端容器并且本地启动
前端dev使用vite构建，具体package.json 文件中定义的脚本，查看 npm run script。
``` bash
docker compose stop frontend
cd frontend
npm run dev
```

## 停止后端容器并且本地启动
```bash
docker compose stop backend
cd backend
fastapi dev app/main.py
```

## 端口改为域名
.dev中修改DOMAIN参数，
Docker Compose 文件将使用它来配置服务的基本域。
Traefik 将使用它的流量传输api.localhost.tiangolo.com到后端，并将流量传输dashboard.localhost.tiangolo.com到前端。
域名localhost.tiangolo.com是一个特殊域名，其（及其所有子域名）配置为指向127.0.0.1。这样您就可以将其用于本地开发。
```bash
DOMAIN=localhost.tiangolo.com
docker compose watch
```

## 预提交和代码检查
Git 钩子脚本可用于在提交代码审查之前识别简单问题。我们在每次提交时运行钩子，以自动指出代码中的问题，例如缺少分号、尾随空格和调试语句。通过在代码审查之前指出这些问题，这允许代码审查者专注于更改的架构，而不会浪费时间在琐碎的风格挑剔上。查看.pre-commit-config.yaml配置文件。

### 安装 precommit 以自动运行
```bash
uv run pre-commit install
```
现在，无论何时您尝试提交，例如：git commit。pre-commit 将运行并检查和格式化您即将提交的代码，并在提交之前要求您再次使用 git 添加该代码。然后您可以git add再次修改/修复文件，现在就可以提交。

### 手动运行预提交钩子
您还可以pre-commit手动运行所有文件，可以使用以下命令执行此操作uv：
```bash
uv run pre-commit run --all-files
```





## 网址
生产或暂存 URL 将使用这些相同的路径，但使用您自己的域。

### 开发 URL，用于本地开发。
前端：http://localhost:5173
后端：http://localhost:8000
自动交互文档（Swagger UI）：http://localhost:8000/docs
自动替代文档（ReDoc）：http://localhost:8000/redoc
管理员：http://localhost:8080
Traefik 用户界面：http://localhost:8090
邮件捕捉器：http://localhost:1080
localhost.tiangolo.com已配置的开发 URL

### 开发 URL，用于本地开发。
前端：http://dashboard.localhost.tiangolo.com
后端：http://api.localhost.tiangolo.com
自动交互文档（Swagger UI）： http: //api.localhost.tiangolo.com/docs
自动替代文档（ReDoc）： http: //api.localhost.tiangolo.com/redoc
管理员：http://localhost.tiangolo.com:8080
Traefik 用户界面：http://localhost.tiangolo.com:8090
邮件捕手：http://localhost.tiangolo.com:1080