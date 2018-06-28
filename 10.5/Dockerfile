#####################
#  Building Stage   #
#####################
FROM gitlab/gitlab-ce:10.5.8-ce.0 as builder

ENV GITLAB_DIR=/opt/gitlab/embedded/service/gitlab-rails
ENV GITLAB_GIT_ZH=https://gitlab.com/xhang/gitlab.git

# Reference:
# * https://gitlab.com/gitlab-org/omnibus-gitlab/blob/master/config/software/gitlab-rails.rb
# * https://gitlab.com/gitlab-org/gitlab-ce/blob/master/.gitlab-ci.yml
RUN set -xe \
    && echo " # Preparing ..." \
    && export DEBIAN_FRONTEND=noninteractive \
    && export SSL_CERT_DIR=/etc/ssl/certs/ \
    && export GIT_SSL_CAPATH=/etc/ssl/certs/ \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -yqq lsb-release patch nodejs python build-essential yarn cmake

RUN set -xe \
    && echo " # Generating translation patch ..." \
    && cd /tmp \
    && git clone ${GITLAB_GIT_ZH} gitlab \
    && cd gitlab \
    && export IGNORE_DIRS=':!spec :!features :!.gitignore :!locale :!app/assets/ :!vendor/assets/' \
    && git diff --diff-filter=d v10.5.8..v10.5.8-zh -- . ${IGNORE_DIRS} > ../zh_CN.diff \
    && echo " # Patching ..." \
    && patch -d ${GITLAB_DIR} -p1 < ../zh_CN.diff \
    && echo " # Copy assets files ..." \
    && git checkout v10.5.8-zh \
    && cp -R locale ${GITLAB_DIR}/ \
    && mkdir -p ${GITLAB_DIR}/app \
    && cp -R app/assets ${GITLAB_DIR}/app/ \
    && mkdir -p ${GITLAB_DIR}/vendor \
    && cp -R vendor/assets ${GITLAB_DIR}/vendor/

RUN set -xe \
    && echo " # Regenerating the assets" \
    && cd ${GITLAB_DIR} \
    && cp config/gitlab.yml.example config/gitlab.yml \
    && cp config/database.yml.postgresql config/database.yml \
    && cp config/secrets.yml.example config/secrets.yml \
    && rm -rf public/assets \
    && export NODE_ENV=production \
    && export RAILS_ENV=production \
    && export SETUP_DB=false \
    && export USE_DB=false \
    && export SKIP_STORAGE_VALIDATION=true \
    && export WEBPACK_REPORT=true \
    && export NO_COMPRESSION=true \
    && export NO_PRIVILEGE_DROP=true \
    && export NODE_OPTIONS=--max-old-space-size=4086 \
    && yarn install --frozen-lockfile \
    && bundle exec rake gettext:compile \
    && bundle exec rake gitlab:assets:compile

RUN set -xe \
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
        app/assets \
        node_modules \
    && find /usr/lib/ -name __pycache__ | xargs rm -rf \
    && rm -rf /tmp/gitlab /tmp/*.diff /root/.cache /var/lib/apt/lists/*


######################
#  Production Stage  #
######################
FROM gitlab/gitlab-ce:10.5.8-ce.0 as production

RUN set -xe \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -yqq locales tzdata \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV TZ=Asia/Shanghai

ENV GITLAB_VERSION=v10.5.8
ENV GITLAB_DIR=/opt/gitlab/embedded/service/gitlab-rails
ENV GITLAB_GIT_ZH=https://gitlab.com/xhang/gitlab.git
ENV GITLAB_GIT_COMMIT_UPSTREAM=v10.5.8
ENV GITLAB_GIT_COMMIT_ZH=v10.5.8-zh

COPY --from=builder ${GITLAB_DIR}/app                   ${GITLAB_DIR}/app
COPY --from=builder ${GITLAB_DIR}/public                ${GITLAB_DIR}/public
COPY --from=builder ${GITLAB_DIR}/config/application.rb ${GITLAB_DIR}/config/application.rb
COPY --from=builder ${GITLAB_DIR}/config/initializers   ${GITLAB_DIR}/config/initializers
COPY --from=builder ${GITLAB_DIR}/config/locales        ${GITLAB_DIR}/config/locales
COPY --from=builder ${GITLAB_DIR}/lib/gitlab            ${GITLAB_DIR}/lib/gitlab
COPY --from=builder ${GITLAB_DIR}/locale                ${GITLAB_DIR}/locale
