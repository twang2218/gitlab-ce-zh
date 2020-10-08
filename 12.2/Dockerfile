######################
#  Production Stage  #
######################
ARG GITLAB_CE_BASE_VERSION=12.2.8
FROM gitlab/gitlab-ce:${GITLAB_CE_BASE_VERSION}-ce.0 AS production
MAINTAINER "blueapple <blueapple1120@qq.com>"

ENV GITLAB_VERSION=v12.2.8
ENV GITLAB_DIR=/opt/gitlab/embedded/service/gitlab-rails
ENV GITLAB_GIT_ZH=https://gitlab.com/xhang/gitlab.git
ENV GITLAB_GIT_COMMIT_UPSTREAM=v12.2.8
ENV GITLAB_GIT_COMMIT_ZH=v12.2.8-zh
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV TZ=Asia/Shanghai

RUN set -xe \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -yqq locales tzdata \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    && wget -c -O /tmp/gitlab-${GITLAB_VERSION}-zh.tar.gz \
       https://gitlab.com/xhang/gitlab/-/archive/${GITLAB_VERSION}-zh/gitlab-${GITLAB_VERSION}-zh.tar.gz \
    && cd /tmp \
    && tar xf gitlab-${GITLAB_VERSION}-zh.tar.gz

RUN yes|cp -ar /tmp/gitlab-${GITLAB_VERSION}-zh/* ${GITLAB_DIR}/
