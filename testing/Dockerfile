FROM gitlab/gitlab-ce:10.0.0-ce.0

ENV GITLAB_VERSION=10-0-stable-zh

RUN set -xe \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -yqq locales tzdata \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV TZ=Asia/Shanghai

ENV GITLAB_DIR=/opt/gitlab/embedded/service/gitlab-rails
ENV GITLAB_ZH_GIT=https://gitlab.com/xhang/gitlab.git

# Reference:
# * https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/config/software/gitlab-rails.rb
# * https://gitlab.com/gitlab-org/gitlab-ce/blob/master/.gitlab-ci.yml
RUN set -xe \
    && echo " # Preparing ..." \
    && export DEBIAN_FRONTEND=noninteractive \
    && export SSL_CERT_DIR=/etc/ssl/certs/ \
    && export GIT_SSL_CAPATH=/etc/ssl/certs/ \
    && curl -sL https://deb.nodesource.com/setup_6.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && export buildDeps='lsb-release patch nodejs python build-essential yarn=0.27.5-1 cmake' \
    && apt-get install -yqq $buildDeps \
    && echo " # Generating translation patch ..." \
    && cd /tmp \
    && git clone ${GITLAB_ZH_GIT} gitlab \
    && cd gitlab \
    && export REVISION=$(cat ${GITLAB_DIR}/REVISION) \
    && export IGNORE_DIRS=':!spec :!features :!.gitignore :!locale :!app/assets/javascripts/locale' \
    && git diff --diff-filter=d v10.0.0..origin/10-0-stable-zh -- . ${IGNORE_DIRS} > ../zh_CN.diff \
    && echo " # Patching ..." \
    && patch -d ${GITLAB_DIR} -p1 < ../zh_CN.diff \
    && echo " # Copy locale files ..." \
    && cp -R locale ${GITLAB_DIR}/ \
    && echo " # Install missing Gem packages ..." \
    && cd ${GITLAB_DIR} \
    && bundle install \
    && echo " # Regenerating the assets" \
    && cd ${GITLAB_DIR} \
    && cp config/gitlab.yml.example config/gitlab.yml \
    && cp config/database.yml.postgresql config/database.yml \
    && cp config/secrets.yml.example config/secrets.yml \
    && rm -rf public/assets \
    && rm -rf yarn.lock node_modules \
    && export NODE_ENV=production \
    && export RAILS_ENV=production \
    && export SETUP_DB=false \
    && export USE_DB=false \
    && export SKIP_STORAGE_VALIDATION=true \
    && export WEBPACK_REPORT=true \
    && export NO_COMPRESSION=true \
    && export NO_PRIVILEGE_DROP=true \
    && yarn install --frozen-lockfile \
    && bundle exec rake gettext:compile \
    && bundle exec rake gitlab:assets:compile \
    && echo " # Cleaning ..." \
    && yarn cache clean \
    && rm -rf log \
        tmp \
        config/gitlab.yml \
        config/database.yml \
        config/secrets.yml \
        .secret \
        .gitlab_shell_secret \
        .gitlab_workhorse_secret \
        node_modules \
    && apt-get purge -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false \
        -o APT::AutoRemove::SuggestsImportant=false \
        $buildDeps \
    && find /usr/lib/ -name __pycache__ | xargs rm -rf \
    && rm -rf /tmp/gitlab /tmp/*.diff /root/.cache /var/lib/apt/lists/*
