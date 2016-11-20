FROM gitlab/gitlab-ce:8.13.5-ce.0
MAINTAINER MaiKeBing github.cn

RUN echo "" \
    && echo "#git clone https://gitlab.com/xhang/gitlab.git" \
    &&  git clone https://github.com/marbleqi/gitlab-ce-zh.git --progress --branch 8-13-5-zh-rel  \
    && echo "# Generating translation patch" \
    && cd gitlab-ce-zh \
    && echo "# Patching" \
    && cp ./*  /opt/gitlab/embedded/service/gitlab-rails  -R \
    && echo "# Cleaning" \
    && cd .. \
    && rm -rf  gitlab-ce-zh
