# 支持的 tags 和对应的 `Dockerfile`

- [`8.5`, `8.5.8` (*8.5/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/9d86cefb639415d0109e8e40c7f0e867b62af7dc/8.5/Dockerfile)
- [`8.6`, `8.6.7` (*8.6/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/9d86cefb639415d0109e8e40c7f0e867b62af7dc/8.6/Dockerfile)
- [`8.7`, `8.7.6` (*8.7/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/9d86cefb639415d0109e8e40c7f0e867b62af7dc/8.7/Dockerfile)
- [`8.8`, `8.8.6`, `latest` (*8.8/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/9d86cefb639415d0109e8e40c7f0e867b62af7dc/8.8/Dockerfile)

[![](https://images.microbadger.com/badges/image/twang2218/gitlab-ce-zh.svg)](http://microbadger.com/images/twang2218/gitlab-ce-zh "Get your own image badge on microbadger.com")

# GitLab 中文社区版

这是汉化的 GitLab 社区版 Docker Image，基于官方提供的 Docker Image  [`gitlab/gitlab-ce`](https://hub.docker.com/r/gitlab/gitlab-ce/)
  -  8.8 之前是 Larry Li 的汉化 <https://gitlab.com/larryli/gitlab> 而制作。
  -  8.13 是marbleqi 的汉化  <https://github.com/marbleqi/gitlab-ce-zh> 

[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/twang2218/gitlab-ce-zh)

# 使用

## 使用 Docker Compose

可以使用 Docker Compose 来配置启动，建立一个 `docker-compose.yml`，内容如下：

```yml
version: '2'
services:
    web:
      image: 'twang2218/gitlab-ce-zh:latest'
      restart: always
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
    config: {}
    data: {}
    logs: {}
```

然后使用命令 `docker-compose up -d` 来启动。

## 使用 Docker 命令启动

```bash
docker run --detach \
    --hostname gitlab.example.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    twang2218/gitlab-ce-zh:latest
```

# 登录

第一次启动 GitLab 后，使用下列默认用户和密码登录，并修改密码：

```bash
用户名: `root`
密码: `5iveL!fe`
```

# 相关信息

GitLab Docker 相关操作请参考：

<http://docs.gitlab.com/omnibus/docker/>

# GitLab Community Edition - Chinese Edition

This is GitLab Community Edition docker image with Chinese translation integrated. The Docker image is based on [`gitlab/gitlab-ce`](https://hub.docker.com/r/gitlab/gitlab-ce/), and the Chinese translation is based on Larry Li's work [https://gitlab.com/larryli/gitlab]().
