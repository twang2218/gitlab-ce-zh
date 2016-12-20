# 支持的 tags 和对应的 `Dockerfile`

- [`8.8`, `8.8.6` (*8.8/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.8/Dockerfile)
- [`8.9`, `8.9.11` (*8.9/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.9/Dockerfile)
- [`8.10`, `8.10.13` (*8.10/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.10/Dockerfile)
- [`8.11`, `8.11.11` (*8.11/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.11/Dockerfile)
- [`8.12`, `8.12.13` (*8.12/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.12/Dockerfile)
- [`8.13`, `8.13.10` (*8.13/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.13/Dockerfile)
- [`8.14`, `8.14.5`, `latest` (*8.14/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.14/Dockerfile)
- [`8.15`, `8.15.0-rc1`, `rc` (*8.15/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.15/Dockerfile)
- [`testing` (*testing/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/testing/Dockerfile)

[![](https://images.microbadger.com/badges/image/twang2218/gitlab-ce-zh.svg)](http://microbadger.com/images/twang2218/gitlab-ce-zh "Get your own image badge on microbadger.com")

# GitLab 中文社区版

这是汉化的 GitLab 社区版 Docker Image，基于官方提供的 Docker Image  [gitlab/gitlab-ce](https://hub.docker.com/r/gitlab/gitlab-ce/)，以及 Larry Li 的汉化 <https://gitlab.com/larryli/gitlab> (8.9以前的版本) 和谢航的汉化 <https://gitlab.com/xhang/gitlab> (8.9 以后的版本) 而制作。

[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/twang2218/gitlab-ce-zh)

# 使用

## 简单运行

如果想简单的运行一下看看，可以执行这个命令：

```bash
docker run -d -p 3000:80 twang2218/gitlab-ce-zh:8.14.5
```

*可以将 `8.14.5` 换成你所需要的版本标签。*

启动后就可以通过主机的 `3000` 端口看到运行结果了，比如用的是本机 Docker 的话，访问：<http://localhost:3000> 即可。

测试结束后，彻底清除容器可以用命令：

```bash
docker rm -fv <容器ID>
```

这样可以停止、删除容器，并清除数据。

## 使用 Docker Compose

正常部署时，可以使用 Docker Compose 来配置启动。建立一个 `docker-compose.yml`，内容如下：

```yml
version: '2'
services:
    gitlab:
      image: 'twang2218/gitlab-ce-zh:8.14.5'
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

**如果你的服务器有域名，将上面的 `gitlab.example.com` 替换为实际域名。**

实验时，也可以直接修改 `/etc/hosts` 方便测试。比如：

```bash
127.0.0.1   gitlab.example.com
```

## 使用 Docker 命令启动

直接使用 `docker` 命令要比使用 `docker-compose` 繁琐一些，但是可以达到一样的效果。

首先，Docker 容器数据应该存储于卷中，在这里我们使用最简单的本地命名卷，因此我们先来创建命名卷。

```bash
docker volume create --name gitlab-config
docker volume create --name gitlab-data
docker volume create --name gitlab-logs
```

顾名思义，`gitlab-config` 存储 GitLab 配置信息；`gitlab-data` 存储数据库；`gitlab-logs` 存储日志。

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
    twang2218/gitlab-ce-zh:8.14.5
```

如需停止服务，直接运行 `docker stop gitlab`。

如需卸载服务及相关内容，可以执行：

```bash
docker stop gitlab
docker rm gitlab
docker network rm gitlab-net
docker volume rm gitlab-config gitlab-datagitlab-logs
```

## `testing` 镜像

`testing` 镜像是为了帮助翻译项目制作的 GitLab 镜像，它始终使用最新的翻译结果。

它是比较 [xhang 翻译项目](https://gitlab.com/xhang/gitlab) 的 `v8.15.0-rc1` 标签和 `8-15-stable-zh` 分支的差异生成汉化补丁，并基于官方镜像 `gitlab/gitlab-ce:v8.15.0-rc1` 进行应用汉化结果进行构建的。

测试镜像将会在 [`8-15-stable-zh` 分支](https://gitlab.com/xhang/gitlab/commits/8-15-stable-zh) 发生改变后 10 分钟内进行镜像构建，从而确保最新的翻译改变可以反映到测试镜像中，方便测试翻译结果。

运行测试镜像和运行其它镜像一样，可以用 `docker-compose` 的方法，也可以用之前最简命令的方法：

```bash
docker pull twang2218/gitlab-ce-zh:testing
docker run -d -p 3000:80 twang2218/gitlab-ce-zh:testing
```

需要注意的是，这里的 `docker pull` 是必须的，因为 `testing` 镜像构建比较频繁，需要确保本地镜像是最新的镜像。如果是 `docker-compose`，则执行 `docker-compose pull` 来或取最新镜像。

## 注意事项

### 登录

启动 GitLab 后，第一次访问时，会要求设置 `root` 用户的密码，密码不得小于8位。设置好后，就可以登录使用了。

对于早期版本，可以使用默认的 `root` 用户密码 `5iveL!fe` 登录。

### 配置 SSH 端口

这里运行示例中，无论是使用 `docker-compose.yml` 还是 `docker run` 都使用的是 SSH 默认端口 `22` 去映射容器 SSH 端口。其目的是希望比较自然的使用类似 `git@gitlab.example.com:myuser/awesome-project.git` 的形式来访问服务器版本库。但是，宿主服务器上默认的 SSH 服务也是使用的 22 端口。因此默认会产生端口冲突。

#### 修改宿主的 SSH 端口

修改宿主的 SSH 端口，使用非 `22` 端口。比如修改 SSHD 配置文件，`/etc/ssh/sshd_config`，将其中的 `Port 22` 改为其它端口号，然后 `service sshd restart`。这种方式比较推荐，因为管理用的宿主 SSH 端口改成别的其实更安全。

#### 修改容器的 SSH 端口

修改容器的端口映射关系，比如将 `-p 22:22` 改为 `-p 2222:22`，这样 GitLab 的 SSH 服务端口将是 `2222`。这样做会让使用 GitLab 的 SSH 克隆、提交代码有些障碍。这种情况要改变用户使用 Git 的链接方式。

要从之前的：

```bash
git clone git@gitlab.example.com:myuser/awesome-project.git
```

改为明确使用 `ssh://` 的 URL 方式。

```bash
git clone ssh://git@gitlab.example.com:2222/myuser/awesome-project.git
```

# 相关信息

GitLab Docker 相关操作请参考：<http://docs.gitlab.com/omnibus/docker/>
GitLab 官方英文社区版 Docker 镜像：<https://hub.docker.com/r/gitlab/gitlab-ce/>
GitLab 官方英文企业版 Docker 镜像：<https://hub.docker.com/r/gitlab/gitlab-ee/>

# GitLab Community Edition - Chinese Edition

This is GitLab Community Edition docker image with Chinese translation integrated. The Docker image is based on [gitlab/gitlab-ce](https://hub.docker.com/r/gitlab/gitlab-ce/), and the Chinese translation is based on Larry Li's work <https://gitlab.com/larryli/gitlab> (pre-8.9) and Xie Hang's work <https://gitlab.com/xhang/gitlab> (8.9+).
