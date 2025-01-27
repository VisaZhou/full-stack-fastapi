# FastAPI 项目 - 部署
您可以使用 Docker Compose 将项目部署到远程服务器。
该项目要求您有一个 Traefik 代理来处理与外界的通信和 HTTPS 证书。
您可以使用 CI/CD（持续集成和持续部署）系统进行自动部署，已经有使用 GitHub Actions 执行此操作的配置。
但你必须先配置一些东西。

## 准备
1.准备好并可以使用远程服务器。
2.配置您的域的 DNS 记录以指向您刚刚创建的服务器的 IP。
3.为您的域名配置一个通配符子域名，这样您就可以为不同的服务设置多个子域名，例如*.fastapi-project.example.com。这对于访问不同的组件很有用，例如dashboard.fastapi-project.example.com、api.fastapi-project.example.com、traefik.fastapi-project.example.com、adminer.fastapi-project.example.com等。对于staging，例如dashboard.staging.fastapi-project.example.com、adminer.staging..fastapi-project.example.com、 等也很有用。
4.在远程服务器（Docker Engine，而不是 Docker Desktop）上安装并配置Docker 。
``` bash

```

## 公共传输
我们需要一个 Traefik 代理来处理传入的连接和 HTTPS 证书。
您只需执行一次后续步骤。

### Traefik Docker Compose
创建一个远程目录来存储您的 Traefik Docker Compose 文件：
``` bash
示例：mkdir -p /root/code/traefik-public/
实际：mkdir -p /home/ec2-user/full-stack-fastapi/traefik-public
```
将 Traefik Docker Compose 文件复制到你的服务器。你可以rsync注意：在（本地终端）中运行以下命令来执行此操作：
``` bash
示例：rsync -a docker-compose.traefik.yml root@your-server.example.com:/root/code/traefik-public/
实际：rsync -a -e "ssh -i /Users/zhouxujin/Documents/zhouxujin/document/SSH/Visage-Amazon-EC2-Secret.pem"  /Users/zhouxujin/Documents/zhouxujin/python_projects/full-stack-fastapi/docker-compose.traefik.yml ec2-user@ec2-13-210-64-189.ap-southeast-2.compute.amazonaws.com:/home/ec2-user/full-stack-fastapi/traefik-public/
```

### Traefik 公共网络
这个 Traefik 将期望一个名为 Docker“公共网络”traefik-public来与您的堆栈进行通信。
这样，就会有一个公共的 Traefik 代理来处理与外界的通信（HTTP 和 HTTPS），然后在其后，您可以拥有一个或多个具有不同域的堆栈，即使它们位于同一台服务器上。
要在远程服务器中创建名为“公共网络”的 Docker，traefik-public请运行以下命令：
``` bash
docker network create traefik-public
```

### Traefik 环境变量 export
Traefik Docker Compose 文件需要在启动之前在终端中设置一些环境变量。你可以在远程服务器中运行以下命令来执行此操作。
创建 Dashboard 的 HTTP Basic Auth 的用户名，例如：
``` bash
示例：export USERNAME=admin
实际：export USERNAME=admin
```
创建 Dashboard 的 HTTP Basic Auth 的密码，例如：
``` bash
示例：export PASSWORD=changethis
实际：export PASSWORD=admin
```
使用 openssl 生成 HTTP Basic Auth 密码的“散列”版本并将其存储在环境变量中：
``` bash
export HASHED_PASSWORD=$(openssl passwd -apr1 $PASSWORD)
```
为了验证散列密码是否正确，您可以打印它：
``` bash
echo $HASHED_PASSWORD
```
使用您的服务器的域名创建环境变量，例如：
``` bash
示例：export DOMAIN=fastapi-project.example.com
实际：export DOMAIN=visage126.com
```
使用 Let's Encrypt 的电子邮件创建环境变量如下，注意：您需要设置不同的电子邮件，电子邮件@example.com不起作用。
``` bash
示例：export EMAIL=admin@example.com
实际：export EMAIL=us.zhouxujin126@gmail.com
```

### Traefik 环境变量 .env-traefik
创建.env-traefik文件并上传到docker-compose.traefik.yml同级目录
``` bash
USERNAME=admin
PASSWORD=admin
HASHED_PASSWORD='执行openssl passwd -apr1 admin后的结果，并且需要用单引号括起来转义'
DOMAIN=visage126.com
EMAIL=us.zhouxujin126@gmail.com

rsync -a -e "ssh -i /Users/zhouxujin/Documents/zhouxujin/document/SSH/Visage-Amazon-EC2-Secret.pem"  /Users/zhouxujin/Documents/zhouxujin/python_projects/full-stack-fastapi/.env-traefik ec2-user@ec2-13-210-64-189.ap-southeast-2.compute.amazonaws.com:/home/ec2-user/full-stack-fastapi/traefik-public/
```

### 启动 Traefik Docker Compose
转到远程服务器中复制 Traefik Docker Compose 文件的目录：
``` bash
示例：cd /root/code/traefik-public/
实际：cd /home/ec2-user/full-stack-fastapi/traefik-public/
```
现在，环境变量已设置完毕docker-compose.traefik.yml，您可以运行以下命令启动 Traefik Docker Compose：
``` bash
eport启动示例：docker-compose -f docker-compose.traefik.yml up -d
.env-traefik启动示例：docker-compose --env-file .env-traefik -f docker-compose.traefik.yml up -d
```
如果安装了docker，但是还未安装compose，需要先安装compose
``` bash
# 下载最新版本的 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# 赋予执行权限
sudo chmod +x /usr/local/bin/docker-compose
# 验证安装
docker-compose version
```

## 部署 FastAPI 项目
现在您已经拥有 Traefik，您可以使用 Docker Compose 部署您的 FastAPI 项目。
注意：您可能希望跳到有关使用 GitHub Actions 进行持续部署的部分。

## 环境变量
您需要先设置一些环境变量。
ENVIRONMENT默认情况下设置local（用于开发），但是当部署到服务器时，您可以放置​​类似staging或 production 的内容：
``` bash
export ENVIRONMENT=production
```
DOMAIN默认情况下设置localhost（用于开发），但在部署时您将使用自己的域，例如：
``` bash
export DOMAIN=fastapi-project.example.com
```
您可以设置多个变量，例如：
    PROJECT_NAME：项目名称，用于文档和电子邮件的 API。
    STACK_NAME：用于 Docker Compose 标签和项目名称的堆栈名称，对于 、 等应该不同staging。production您可以使用相同的域将点替换为破折号，例如fastapi-project-example-com和staging-fastapi-project-example-com。
    BACKEND_CORS_ORIGINS：允许的 CORS 来源列表，以逗号分隔。
    SECRET_KEY：FastAPI 项目的密钥，用于签署令牌。
    FIRST_SUPERUSER：第一个超级用户的电子邮件，该超级用户可以创建新用户。
    FIRST_SUPERUSER_PASSWORD：第一个超级用户的密码。
    SMTP_HOST：发送电子邮件的 SMTP 服务器主机，这将来自您的电子邮件提供商（例如 Mailgun、Sparkpost、Sendgrid 等）。
    SMTP_USER：发送邮件的SMTP服务器用户。
    SMTP_PASSWORD：发送电子邮件的 SMTP 服务器密码。
    EMAILS_FROM_EMAIL：发送电子邮件的电子邮件账户。
    POSTGRES_SERVER：PostgreSQL 服务器的主机名。您可以保留由同一 Docker Compose 提供的默认主机名db。除非您使用第三方提供商，否则通常不需要更改此主机名。
    POSTGRES_PORT：PostgreSQL 服务器的端口。您可以保留默认设置。除非您使用第三方提供商，否则通常不需要更改此设置。
    POSTGRES_PASSWORD：Postgres 密码。
    POSTGRES_USER：Postgres 用户，保留默认即可。
    POSTGRES_DB：此应用程序要使用的数据库名称。您可以保留默认值app。
    SENTRY_DSN：如果您正在使用 Sentry，则其 DSN。

## GitHub Actions 环境变量
有一些仅由 GitHub Actions 使用的环境变量您可以配置：
### LATEST_CHANGES：
由 GitHub Action latest-changes使用，具体来说，latest-changes Action 会自动从 PR 中获取信息（例如 PR 描述、提交信息等），然后将这些信息用作发布说明的一部分，帮助生成更清晰的版本更新说明。它的值是个人访问令牌，这个令牌通常是指一个 GitHub 访问令牌，用于授权 GitHub Actions 获取 PR 信息或访问 GitHub API。当你使用 GitHub Actions 时，你需要提供一个 GitHub Personal Access Token（PAT）来进行身份验证，通常是通过环境变量来传递该令牌。
点击头像-->Settings-->Developer Settings-->Personal access tokens创建token(以下是已有的满权限token，无过期时间token)


### SMOKESHOW_AUTH_KEY：
这是与 Smokeshow 集成的环境变量。Smokeshow 是一个服务，主要用于处理和发布代码覆盖率信息，通常用于检测和报告测试覆盖率的工具。通过设置 SMOKESHOW_AUTH_KEY，你可以将你的项目与 Smokeshow 服务集成，在 GitHub Actions 过程中自动上传代码覆盖率报告。创建 Smokeshow 密钥：如果你希望将代码覆盖率数据推送到 Smokeshow，你需要创建一个免费的 Smokeshow 密钥，并将该密钥配置为 SMOKESHOW_AUTH_KEY 环境变量。这样，GitHub Actions 执行时就能使用该密钥与 Smokeshow API 进行通信。

### 生成密钥
文件中的某些环境变量.env具有默认值changethis。
您必须使用密钥来更改它们，要生成密钥，您可以运行以下命令：
``` python
python -c "import secrets; print(secrets.token_urlsafe(32))"
```
复制内容并将其用作密码/密钥。然后再次运行以生成另一个安全密钥。

### 使用 Docker Compose 进行部署
有了环境变量，你就可以使用 Docker Compose 进行部署：
上传.env-prod,并重命名为.env
上传docker-compose.yml
此时未使用自动托管，还需要自己手动上传前端容器和后端容器
``` bash
rsync -a -e "ssh -i /Users/zhouxujin/Documents/zhouxujin/document/SSH/Visage-Amazon-EC2-Secret.pem"  /Users/zhouxujin/Documents/zhouxujin/python_projects/full-stack-fastapi/.env-prod ec2-user@ec2-13-210-64-189.ap-southeast-2.compute.amazonaws.com:/home/ec2-user/full-stack-fastapi/

mv .env-prod .env

rsync -a -e "ssh -i /Users/zhouxujin/Documents/zhouxujin/document/SSH/Visage-Amazon-EC2-Secret.pem"  /Users/zhouxujin/Documents/zhouxujin/python_projects/full-stack-fastapi/docker-compose.yml ec2-user@ec2-13-210-64-189.ap-southeast-2.compute.amazonaws.com:/home/ec2-user/full-stack-fastapi/

docker-compose --env-file .env -f docker-compose.yml up -d
```
对于生产，您不会想在其中进行覆盖docker-compose.override.yml，这就是我们明确指定docker-compose.yml要使用的文件的原因。

# 持续部署 (CD)
您可以使用 GitHub Actions 自动部署您的项目。
您可以有多个环境部署。
已经配置了两个环境，staging和production。

## GitHub Actions Runner
安装 GitHub Action 自托管运行器。
官方指南
``` bash
https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners#adding-a-self-hosted-runner-to-a-repository
```

在仓库下点击Settings-->点击左侧导航Actions-->Runners-->选择Linux

### 下载
``` bash
# 创建自托管文件夹
mkdir actions-runner && cd actions-runner
# 下载
curl -o actions-runner-linux-x64-2.321.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.321.0/actions-runner-linux-x64-2.321.0.tar.gz
# 验证文件完整性和安全性
echo "ba46ba7ce3a4d7236b16fbe44419fb453bc08f866b24f04d549ec89f1722a29e  actions-runner-linux-x64-2.321.0.tar.gz" | shasum -a 256 -c
# 解压缩
tar xzf ./actions-runner-linux-x64-2.321.0.tar.gz
```

### 配置
``` bash
# 这是一个一次性使用的注册令牌，GitHub 提供它来验证 Runner 和仓库之间的关联。
# 你可以在 GitHub 仓库的 Settings > Actions > Runners 页面中找到生成令牌的选项。
# 这个令牌有一定的时效性，用于确保只有授权的 Runner 能注册。如果过期了404需要去github上重新创建
# 根据命令行提示创建步骤进行创建
./config.sh --url https://github.com/VisaZhou/full-stack-fastapi --token AICUKHUMLC2RSCR7S27KJ43HS4P3C
# 托管器组名称
Enter
# 托管器名称
full-stack-fastapi-runner
# 额外的标签名称,已有标签 self-hosted,Linux,X64
Enter
# 工作流名称
Enter

# 如果提示缺少了 .NET Core 6.0 所需的依赖库
sudo yum install -y libicu
# 启动
$ ./run.sh
```

### 使用
``` bash
# Use this YAML in your workflow file for each job
runs-on: self-hosted
```

## 将自托管运行器应用程序配置为服务
### 安装服务
如果自托管运行器应用程序当前正在运行，请停止它。
使用以下命令安装服务：
``` bash
sudo ./svc.sh install
```

### 启动服务
``` bash
sudo ./svc.sh start
```

### 检查服务状态
```bash
sudo ./svc.sh status
```

### 停止服务
``` bash
sudo ./svc.sh stop
```
### 卸载服务
``` bash
sudo ./svc.sh uninstall
```
自定义自托管运行器服务
如果您不想使用上述默认systemd服务配置，您可以创建自定义服务或使用您喜欢的任何服务机制。请考虑使用 处的serviced模板actions-runner/bin/actions.runner.service.template作为参考。如果您使用自定义服务，则必须始终使用入口点调用自托管运行器服务runsvc.sh。
您可以在官方指南中阅读更多相关信息：将自托管运行器应用程序配置为服务。
``` bash
https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/configuring-the-self-hosted-runner-application-as-a-service
```

### 设置密钥
在你的仓库中，配置你需要的环境变量的机密，与上面描述的相同，包括SECRET_KEY等。按照官方 GitHub 指南设置仓库机密。
``` bash
https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository
```
当前的 Github Actions 工作流程需要以下机密：
``` bash
    DOMAIN_PRODUCTION=
    DOMAIN_STAGING=visage.com
    STACK_NAME_PRODUCTION=
    STACK_NAME_STAGING=full-stack-fastapi-staging
    EMAILS_FROM_EMAIL=info@example.com
    FIRST_SUPERUSER=admin@example.com
    FIRST_SUPERUSER_PASSWORD=zxj201328
    POSTGRES_PASSWORD=zxj201328
    SECRET_KEY=zxj201328
    LATEST_CHANGES=
    SMOKESHOW_AUTH_KEY=
```
## GitHub Action 部署工作流程
.github/workflows目录中已配置了用于部署到环境的 GitHub Action 工作流程（带有标签的 GitHub Actions 运行器）：
    staging：推送（或合并）到分支后master。
    production：发布版本后。
如果您需要添加额外的环境，您可以将它们用作起点。

### 网址
替换fastapi-project.example.com为您的域名。

### 主 Traefik 仪表板
Traefik 用户界面：https://traefik.fastapi-project.example.com

### 生产
前端：https://dashboard.fastapi-project.example.com
后端 API 文档：https://api.fastapi-project.example.com/docs
后端 API 基本 URL：https://api.fastapi-project.example.com
管理人：https://adminer.fastapi-project.example.com

### 分期
前端：https://dashboard.staging.fastapi-project.example.com
后端 API 文档：https://api.staging.fastapi-project.example.com/docs
后端 API 基本 URL：https://api.staging.fastapi-project.example.com
管理人：https://adminer.staging.fastapi-project.example.com