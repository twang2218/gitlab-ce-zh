FROM gitlab/gitlab-ce:8.15.3-ce.0
ENV GITLAB_VERSION=8-15-stable-zh
RUN set -xe \
    && echo " # Generating translation patch ..." \
    && git clone https://gitlab.com/xhang/gitlab.git \
    && cd gitlab \
    && git diff v8.15.3..origin/8-15-stable-zh > ../zh_CN.diff \
    && echo " # Patching ..." \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Install missing Gem packages ..." \
    && CURRENT_DIR=$PWD \
    && cd /opt/gitlab/embedded/service/gitlab-rails \
    && bundle install \
    && cd $CURRENT_DIR \
    && echo " # Cleaning ..." \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
