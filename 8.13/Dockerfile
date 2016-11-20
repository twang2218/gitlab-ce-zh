FROM gitlab/gitlab-ce:8.13.6-ce.0
MAINTAINER Tao Wang <twang2218@gmail.com>
RUN set -xe \
    && VERSION=v8.13.6 \
    && echo " # Generating translation patch ..." \
    && git clone https://gitlab.com/xhang/gitlab.git \
    && cd gitlab \
    && git remote add upstream https://gitlab.com/gitlab-org/gitlab-ce.git \
    && git fetch --depth=1 upstream tag ${VERSION} \
    && git diff ${VERSION}..origin/8-13-6-zh > ../zh_CN.diff \
    && echo " # Patching ..." \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Cleaning ..." \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
