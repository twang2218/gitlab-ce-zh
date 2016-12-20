FROM gitlab/gitlab-ce:8.11.11-ce.0

RUN set -xe \
    && git clone https://gitlab.com/xhang/gitlab.git \
    && echo " # Generating translation patch" \
    && cd gitlab \
    && git diff origin/8-11-stable..origin/8-11-stable-zh > ../zh_CN.diff \
    && echo " # Patching" \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo " # Cleaning" \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
