FROM gitlab/gitlab-ce:8.8.6-ce.1

RUN echo "" \
    && echo "# git clone https://gitlab.com/larryli/gitlab.git" \
    && git clone https://gitlab.com/larryli/gitlab.git \
    && echo "# Generating translation patch" \
    && cd gitlab \
    && git diff origin/8-8-stable..origin/8-8-zh > ../zh_CN.diff \
    && echo "# Patching" \
    && patch -d /opt/gitlab/embedded/service/gitlab-rails -p1 < ../zh_CN.diff \
    && echo "# Cleaning" \
    && cd .. \
    && rm -rf gitlab \
    && rm *.diff
