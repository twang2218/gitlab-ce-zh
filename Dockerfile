FROM gitlab/gitlab-ce:8.3.9-ce.0
MAINTAINER Tao Wang <twang2218@gmail.com>

RUN echo "" \
    && echo "# git clone https://gitlab.com/larryli/gitlab.git" \
    && git clone https://gitlab.com/larryli/gitlab.git \
    && echo "# Generating translation patch" \
    && cd gitlab \
    && git diff origin/8-3-stable..origin/8-3-zh > ../zh_CN.diff \
    && echo "# Patching" \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo "# Cleaning" \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
