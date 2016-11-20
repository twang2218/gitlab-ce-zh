FROM gitlab/gitlab-ce:8.13.6-ce.0
MAINTAINER MaiKeBing github.cn

RUN echo "" \
    && echo "# git clonehttps://gitlab.com/xhang/gitlab.git" \
    && git clone --progress --branch 8-13-6-zh  \
    && echo "# Generating translation patch" \
    && cd gitlab \
    && echo "# Patching" \
    && cp ./*  /opt/gitlab/embedded/service/gitlab-rails  -R \
    && echo "# Cleaning" \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
