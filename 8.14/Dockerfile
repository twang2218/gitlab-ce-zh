FROM gitlab/gitlab-ce:8.14.0-ce.0
MAINTAINER Tao Wang <twang2218@gmail.com>
RUN set -xe \
    && echo " # Generating translation patch ..." \
    && git clone https://gitlab.com/twang2218/gitlab.git \
    && cd gitlab \
    && git diff origin/8-14-stable..origin/8-14-stable-zh > ../zh_CN.diff \
    && echo " # Patching ..." \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Cleaning ..." \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
