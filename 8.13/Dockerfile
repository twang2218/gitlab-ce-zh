FROM gitlab/gitlab-ce:8.13.5-ce.0
MAINTAINER Tao Wang <twang2218@gmail.com>
RUN set -xe \
    && VERSION=v8.13.5 \
    && echo " # Generating translation patch ..." \
    && git clone --depth=1 https://gitlab.com/xhang/gitlab.git \
    && cd gitlab \
    && git fetch --depth=1 origin tag ${VERSION}.zh \
    && git remote add upstream https://gitlab.com/gitlab-org/gitlab-ce.git \
    && git fetch --depth=1 upstream tag ${VERSION} \
    && git diff ${VERSION}..${VERSION}.zh > ../zh_CN.diff \
    && echo " # Patching ..." \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Cleaning ..." \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
