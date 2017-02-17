FROM gitlab/gitlab-ce:8.15.6-ce.0

ENV GITLAB_VERSION=v8.15.6
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

RUN set -xe \
    && cd / \
    && echo " # Generating translation patch ..." \
    && git clone https://gitlab.com/xhang/gitlab.git \
    && cd gitlab \
    && git diff v8.15.6..v8.15.6-zh > ../zh_CN.diff \
    && echo " # Patching ..." \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Regenerating the assets" \
    && cd /opt/gitlab/embedded/service/gitlab-rails \
    && cp config/gitlab.yml.example config/gitlab.yml \
    && cp config/database.yml.postgresql config/database.yml \
    && cp config/secrets.yml.example config/secrets.yml \
    && rm -rf public/assets \
    && RAILS_ENV=production \
        NO_PRIVILEGE_DROP=true \
        USE_DB=false \
        SKIP_STORAGE_VALIDATION=true \
        bundle exec rake assets:clean assets:precompile \
    && rm -rf /opt/gitlab/embedded/service/gitlab-rails/log \
        /opt/gitlab/embedded/service/gitlab-rails/tmp \
        config/gitlab.yml \
        config/database.yml \
        config/secrets.yml \
        .secret \
        .gitlab_shell_secret \
        .gitlab_workhorse_secret \
    && echo " # Cleaning ..." \
    && rm -rf /gitlab /*.diff
