FROM gitlab/gitlab-ce:8.9.11-ce.0
MAINTAINER Tao Wang <twang2218@gmail.com>

RUN set -xe \
    && git clone https://gitlab.com/xhang/gitlab.git \
    && echo " # Generating translation patch" \
    && cd gitlab \
    && git remote add upstream https://gitlab.com/gitlab-org/gitlab-ce.git \
    && git fetch upstream 8-9-stable \
    && git diff upstream/8-9-stable..origin/8-9-zh > ../zh_CN.diff \
    && echo " # Patching" \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Cleaning" \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
