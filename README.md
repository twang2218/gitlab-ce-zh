# 支持的 tags 和对应的 `Dockerfile`

- [`8.8`, `8.8.6` (*8.8/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.8/Dockerfile)
- [`8.9`, `8.9.11` (*8.9/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.9/Dockerfile)
- [`8.12`, `8.12.9` (*8.12/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.12/Dockerfile)
- [`8.13`, `8.13.6`, `latest` (*8.13/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.13/Dockerfile)
- [`8.14`, `testing` (*8.14/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.14/Dockerfile)

[![](https://images.microbadger.com/badges/image/twang2218/gitlab-ce-zh.svg)](http://microbadger.com/images/twang2218/gitlab-ce-zh "Get your own image badge on microbadger.com")

# GitLab 中文社区版

这是汉化的 GitLab 社区版 Docker Image，基于官方提供的 Docker Image  [`gitlab/gitlab-ce`](https://hub.docker.com/r/gitlab/gitlab-ce/)，以及 Larry Li 的汉化 <https://gitlab.com/larryli/gitlab> 和 谢航 的汉化 <https://gitlab.com/xhang/gitlab> 而制作。

[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/twang2218/gitlab-ce-zh)

# 使用

## 使用 Docker Compose

可以使用 Docker Compose 来配置启动，建立一个 `docker-compose.yml`，内容如下：

```yml
version: '2'
services:
    gitlab:
      image: 'twang2218/gitlab-ce-zh:latest'
      restart: unless-stopped
      hostname: 'gitlab.example.com'
      environment:
        GITLAB_OMNIBUS_CONFIG: |
          external_url 'http://gitlab.example.com'
          # Add any other gitlab.rb configuration here, each on its own line
      ports:
        - '80:80'
        - '443:443'
        - '22:22'
      volumes:
        - config:/etc/gitlab
        - data:/var/opt/gitlab
        - logs:/var/log/gitlab
volumes:
    config:
    data:
    logs:
```

然后使用命令 `docker-compose up -d` 来启动，停止服务使用 `docker-compose down`。

实验时，可以直接修改 `/etc/hosts` 添加 Docker Host 的主机 IP 以及域名，方便测试。比如，对于 Docker for Mac 环境来说，可以直接在 `/etc/hosts` 添加下面这一行：

```bash
127.0.0.1   gitlab.example.com
```

## 直接使用 Docker 命令启动

直接使用 `docker` 命令要比使用 `docker-compose` 繁琐一些，但是可以达到一样的效果。

首先，Docker 容器数据应该存储于卷中，在这里我们使用最简单的本地命名卷，因此我们先来创建命名卷。

```bash
docker volume create --name gitlab-config
docker volume create --name gitlab-data
docker volume create --name gitlab-logs
```

然后我们需要创建自定义网络，从而让容器运行于独立的网络中，区别于默认网桥。

```bash
docker network create gitlab-net
```

准备好后，开始运行 Gitlab 容器：

```bash
docker run -d \
    --hostname gitlab.example.com \
    -p 80:80 \
    -p 443:443 \
    -p 22:22 \
    --name gitlab \
    --restart unless-stopped \
    -v gitlab-config:/etc/gitlab \
    -v gitlab-logs:/var/log/gitlab \
    -v gitlab-data:/var/opt/gitlab \
    --network gitlab-net \
    twang2218/gitlab-ce-zh:latest
```

如需停止服务，直接运行 `docker stop gitlab`。

如需卸载服务及相关内容，可以执行：

```bash
docker stop gitlab
docker rm gitlab
docker network rm gitlab-net
docker volume rm gitlab-config
docker volume rm gitlab-data
docker volume rm gitlab-logs
```

# 登录

启动 GitLab 后，第一次访问时，会要求设置 `root` 用户的密码，密码不得小于8位。设置好后，就可以登录使用了。

# 相关信息

GitLab Docker 相关操作请参考：

<http://docs.gitlab.com/omnibus/docker/>

# GitLab Community Edition - Chinese Edition

This is GitLab Community Edition docker image with Chinese translation integrated. The Docker image is based on [`gitlab/gitlab-ce`](https://hub.docker.com/r/gitlab/gitlab-ce/), and the Chinese translation is based on Larry Li's work <https://gitlab.com/larryli/gitlab> and Xie Hang's work <https://gitlab.com/xhang/gitlab>.
