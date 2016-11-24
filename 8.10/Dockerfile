FROM gitlab/gitlab-ce:8.10.13-ce.0
MAINTAINER Tao Wang <twang2218@gmail.com>

RUN set -xe \
    && git clone https://gitlab.com/xhang/gitlab.git \
    && echo " # Generating translation patch" \
    && cd gitlab \
    && git diff origin/8-10-stable..origin/8-10-zh > ../zh_CN.diff \
    && echo " # Patching" \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Cleaning" \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
