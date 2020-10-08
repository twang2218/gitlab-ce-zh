######################
#  Production Stage  #
######################
FROM gitlab/gitlab-ce:12.3.5-ce.0 as production

RUN set -xe \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -yqq locales tzdata \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    && wget -c -O /tmp/gitlab-v12.3.5-zh.tar.gz https://gitlab.com/xhang/gitlab/-/archive/v12.3.5-zh/gitlab-v12.3.5-zh.tar.gz \
    && cd /tmp \
    && tar xf /tmp/gitlab-v12.3.5-zh.tar.gz

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV TZ=Asia/Shanghai

ENV GITLAB_VERSION=v12.3.5
ENV GITLAB_DIR=/opt/gitlab/embedded/service/gitlab-rails
ENV GITLAB_GIT_ZH=https://gitlab.com/xhang/gitlab.git
ENV GITLAB_GIT_COMMIT_UPSTREAM=v12.3.5
ENV GITLAB_GIT_COMMIT_ZH=v12.3.5-zh

RUN yes|cp -ar /tmp/gitlab-v12.3.5-zh/* ${GITLAB_DIR}/ \
    && rm -rf /tmp/gitlab-v12.3.5-zh.tar.gz \
             /tmp/gitlab-v12.3.5-zh/ 
