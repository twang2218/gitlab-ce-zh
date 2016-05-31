# GitLab 中文社区版

这是汉化的 GitLab 社区版 Docker Image，基于官方提供的 [`gitlab/gitlab-ce`](https://hub.docker.com/r/gitlab/gitlab-ce/)，以及 Larry Li 的汉化[https://gitlab.com/larryli/gitlab]() 而制作。

# 使用

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

第一次启动 GitLab 后，使用下列默认用户和密码登录，并修改密码：

```
用户名: `root`
密码: `5iveL!fe`
```

GitLab Docker 相关操作请参考：

http://docs.gitlab.com/omnibus/docker/

# GitLab Community Edition - Chinese Edition

This is GitLab Community Edition docker image with Chinese translation integrated. The Docker image is based on [`gitlab/gitlab-ce`](https://hub.docker.com/r/gitlab/gitlab-ce/), and the Chinese translation is based on Larry Li's work [https://gitlab.com/larryli/gitlab]().
