# 支持的 tags 和对应的 `Dockerfile`

- [`8.15`, `8.15.8` (*8.15/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.15/Dockerfile)
- [`8.16`, `8.16.9` (*8.16/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.16/Dockerfile)
- [`8.17`, `8.17.6` (*8.17/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/8.17/Dockerfile)
- [`9.0`, `9.0.7` (*9.0/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/9.0/Dockerfile)
- [`9.1`, `9.1.3` (*9.1/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/9.1/Dockerfile)
- [`9.2`, `9.2.2`, `latest` (*9.2/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/9.2/Dockerfile)
- [`testing` (*testing/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/testing/Dockerfile)
- [`master` (*master/Dockerfile*)](https://github.com/twang2218/gitlab-ce-zh/blob/master/master/Dockerfile)

[![Build Status](https://travis-ci.org/twang2218/gitlab-ce-zh.svg?branch=master)](https://travis-ci.org/twang2218/gitlab-ce-zh)
[![Image Layers and Size](https://images.microbadger.com/badges/image/twang2218/gitlab-ce-zh.svg)](http://microbadger.com/images/twang2218/gitlab-ce-zh)
[![Deploy to Docker Cloud](https://files.cloud.docker.com/images/deploy-to-dockercloud.svg)](https://cloud.docker.com/stack/deploy/?repo=https://github.com/twang2218/gitlab-ce-zh)

# GitLab 中文社区版

这是汉化的 GitLab 社区版 Docker Image [twang2218/gitlab-ce-zh](https://hub.docker.com/r/twang2218/gitlab-ce-zh/)，基于官方提供的 Docker Image  [gitlab/gitlab-ce](https://hub.docker.com/r/gitlab/gitlab-ce/)，以及 Larry Li 的汉化 <https://gitlab.com/larryli/gitlab> (8.9以前的版本) 和谢航的汉化 <https://gitlab.com/xhang/gitlab> (8.9 以后的版本) 而制作。

* 如果碰到汉化问题，欢迎到 <https://gitlab.com/xhang/gitlab/issues> 来提交 Issue 甚至 Merge Request；
* 如果碰到镜像问题，欢迎到 <https://github.com/twang2218/gitlab-ce-zh/issues> 来提交 Issue 或 Pull Request。

大家的贡献才能让汉化项目变得更好。如果喜欢本项目，不要忘了加星标啊。 ☺

# 使用

## 简单运行

如果想简单的运行一下看看，可以执行这个命令：

```bash
docker run -d -p 3000:80 twang2218/gitlab-ce-zh:9.1.3
```

*可以将 `9.1.3` 换成你所需要的版本标签。*

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
      image: 'twang2218/gitlab-ce-zh:9.1.3'
      restart: unless-stopped
      hostname: 'gitlab.example.com'
      environment:
        TZ: 'Asia/Shanghai'
        GITLAB_OMNIBUS_CONFIG: |
          external_url 'http://gitlab.example.com'
          gitlab_rails['time_zone'] = 'Asia/Shanghai'
          # 需要配置到 gitlab.rb 中的配置可以在这里配置，每个配置一行，注意缩进。
          # 比如下面的电子邮件的配置：
          # gitlab_rails['smtp_enable'] = true
          # gitlab_rails['smtp_address'] = "smtp.exmail.qq.com"
          # gitlab_rails['smtp_port'] = 465
          # gitlab_rails['smtp_user_name'] = "xxxx@xx.com"
          # gitlab_rails['smtp_password'] = "password"
          # gitlab_rails['smtp_authentication'] = "login"
          # gitlab_rails['smtp_enable_starttls_auto'] = true
          # gitlab_rails['smtp_tls'] = true
          # gitlab_rails['gitlab_email_from'] = 'xxxx@xx.com'
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

首先，Docker 容器数据应该存储于卷中，在这里我们使用最简单的本地命名卷：

* `gitlab-config` 存储 GitLab 配置信息
* `gitlab-data` 存储数据库
* `gitlab-logs` 存储日志

然后，我们需要创建自定义网络，从而让容器运行于独立的网络中，区别于默认网桥。

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
    twang2218/gitlab-ce-zh:9.1.3
```

如果需要进入容器修改配置文件，可以用 `docker exec` 命令进入容器：

```bash
$ docker exec -it gitlab bash
root@09f6e32c528c:/# vi /etc/gitlab/gitlab.rb
root@09f6e32c528c:/# gitlab-ctl reconfigure
Starting Chef Client, version 12.12.15
resolving cookbooks for run list: ["gitlab"]
...
```

如需停止服务，直接运行 `docker stop gitlab`。

如需卸载服务及相关内容，可以执行：

```bash
docker stop gitlab
docker rm gitlab
docker network rm gitlab-net
docker volume rm gitlab-config gitlab-datagitlab-logs
```

## `testing` 和 `master` 镜像

`testing` 镜像以及 `master` 镜像是为了帮助翻译项目测试所制作的 GitLab 镜像，它始终使用最新的翻译结果。

* `testing` 是比较 [xhang 翻译项目](https://gitlab.com/xhang/gitlab) 的 `v9.1.3` 标签和 [`9-1-stable-zh` 分支](https://gitlab.com/xhang/gitlab/tree/9-1-stable-zh) 的差异生成汉化补丁，并基于官方镜像 `gitlab/gitlab-ce:9.1.3-ce.0` 应用汉化结果进行构建的。
* `master` 是比较 [xhang 翻译项目](https://gitlab.com/xhang/gitlab) 的 `v9.1.3` 标签和 [`master-zh` 分支](https://gitlab.com/xhang/gitlab/tree/master-zh) 的差异生成汉化补丁，并基于官方镜像 `gitlab/gitlab-ce:9.1.3-ce.0` 应用汉化结果进行构建的。

测试镜像将会在所对应分支发生改变后数分钟内开始构建镜像，构建成功后，会推送到 [Docker Hub 网站](https://hub.docker.com/r/twang2218/gitlab-ce-zh/)，以方便测试，可以随时关注最新的[镜像标签列表](https://hub.docker.com/r/twang2218/gitlab-ce-zh/tags/)中所对应的构建时间。

运行测试镜像和运行其它镜像一样，可以用 `docker-compose` 的方法，也可以用之前最简命令的方法：

```bash
docker pull twang2218/gitlab-ce-zh:testing
docker run -d -p 3000:80 twang2218/gitlab-ce-zh:testing
```

> 需要注意的是，这里的 `docker pull` 是必须的，因为测试镜像构建比较频繁，需要确保本地镜像是最新的镜像。如果是 `docker-compose`，则执行 `docker-compose pull` 来或取最新镜像。

## `build.sh` 构建脚本

`build.sh` 构建脚本是为了对维护本项目提供支持的脚本。脚本含 5 个子命令，分别为 `branch`、`tag`、`run`、`generate`、`ci`。

其中 `branch`、`tag` 和 `run` 配合使用，可以在不写 `Dockerfile` 的情况下直接生成特定版本、分支的汉化版本镜像。这样方便测试还在开发的分支，或者尚未进入 `twang2218/gitlab-ce-zh` 镜像库的镜像。

而 `generate` 和 `ci` 是维护项目所用的命令。

### `branch` - 构建某个汉化分支的镜像

格式为：`./build.sh branch <基础镜像标签> <英文版本标签> <汉化版本分支>`

例如：`./build.sh branch 9.1.3-ce.0 v9.1.3 8-15-stable-zh`

这表明将使用 `gitlab/gitlab-ce:9.1.3-ce.0` 做为基础镜像，并且使用上游版本标签 `v9.1.3` 作为对比的基础标签版本，也就是对应于基础镜像版本的标签，然后使用汉化分支 `8-15-stable-zh` 进行对比，生成汉化补丁，由此构建一个名为 `twang2218/gitlab-ce-zh:8-15-stable-zh` 的镜像。

### `tag` - 构建某个汉化标签的镜像

格式为：`./build.sh tag <基础镜像标签> <英文版本标签>`

例如： `./build.sh tag 9.1.3-ce.0 v9.1.3`

这表明将使用 `gitlab/gitlab-ce:9.1.3-ce.0` 镜像为基础镜像，以 `v9.1.3` 为基础对比版本，以 `v9.1.3-zh` 为汉化版本进行对比生成汉化补丁，并构建一个名为 `twang2218/gitlab-ce-zh:9.1.3` 的镜像。

### `run` - 运行某个构建好的镜像

格式为：`./build.sh <镜像标签>`

例如： `./build.sh run 9.1.3`

这将会以命令 `docker run -d -P twang2218/gitlab-ce-zh:9.1.3` 来运行镜像。这里使用的是 `-P`，因此会随机映射端口。方便测试环境测试，避免和其它端口冲突。

```bash
CONTAINER ID        IMAGE                         COMMAND             CREATED             STATUS              PORTS                                                                  NAMES
68e03524b2f2        gitlab-ce-zh:8-15-stable-zh   "/assets/wrapper"   3 seconds ago       Up 1 seconds        0.0.0.0:32776->22/tcp, 0.0.0.0:32775->80/tcp, 0.0.0.0:32774->443/tcp   adoring_bartik
```

从 `docker ps` 的结果可以看出，该运行的容器的 `80` 端口映射到了宿主的 `32775` 端口，因此访问 `http://<主机IP>:32775` 就可以看到运行结果。*初次启动会比较慢，要耐心等待。*

### `generate` - 生成 Dockerfile

各个小版本分支的 `Dockerfile`，如 `8.15/Dockerfile` 等，都是使用 `generate` 命令生成的。因此只需要更新 `build.sh` 中的 `generate()` 函数就可以完成各个版本镜像的升级，当然，`README.md` 还需要手动更新。

```bash
./build.sh generate
```

执行之后，可以 `git diff` 查看实际变更情况。

### `ci` - 持续集成脚本

`ci` 命令是为了持续集成服务准备的，现在支持 [Travis CI](https://travis-ci.org/)。

在 Travis CI 被触发后，会调用 `./build.sh ci` 命令。该命令会根据环境变量情况决定是整体各个分支检查、构建、发布，还是针对某个标签检查、构建、发布。

镜像构建成功后，会自动发布到 Docker Hub。这种方式比直接使用 Docker Hub 中的正则匹配要灵活。

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

* GitLab Docker 相关操作请参考：<http://docs.gitlab.com/omnibus/docker/>
* GitLab 官方英文社区版 Docker 镜像：<https://hub.docker.com/r/gitlab/gitlab-ce/>
* GitLab 官方英文企业版 Docker 镜像：<https://hub.docker.com/r/gitlab/gitlab-ee/>

# GitLab Community Edition - Chinese Edition

This is GitLab Community Edition docker image with Chinese translation integrated. The Docker image is based on [gitlab/gitlab-ce](https://hub.docker.com/r/gitlab/gitlab-ce/), and the Chinese translation is based on Larry Li's work <https://gitlab.com/larryli/gitlab> (pre-8.9) and Xie Hang's work <https://gitlab.com/xhang/gitlab> (8.9+).
