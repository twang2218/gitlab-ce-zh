#!/bin/bash

function generate() {
    version_8_17=8.17.6
    version_9_0=9.0.10
    version_9_1=9.1.7
    version_9_2=9.2.7
    version_9_3=9.3.0
    version_latest=${version_9_3}
    testing_version=${version_9_3}
    testing_tag=${testing_version}-ce.0
    testing_branch=9-3-stable-zh

    generate_tag_v8_17_dockerfile       ${version_8_17}-ce.0    v${version_8_17}    v${version_8_17}-zh     > 8.17/Dockerfile
    generate_tag_v8_17_dockerfile       ${version_9_0}-ce.0     v${version_9_0}     v${version_9_0}-zh      > 9.0/Dockerfile
    generate_tag_v8_17_dockerfile       ${version_9_1}-ce.0     v${version_9_1}     v${version_9_1}-zh      > 9.1/Dockerfile
    generate_tag_v8_17_dockerfile       ${version_9_2}-ce.0     v${version_9_2}     v${version_9_2}-zh      > 9.2/Dockerfile
    generate_tag_v8_17_dockerfile       ${version_9_3}-ce.0     v${version_9_3}     v${version_9_3}-zh      > 9.3/Dockerfile
    generate_branch_v8_17_dockerfile    ${testing_tag}          v${testing_version} ${testing_branch}       > testing/Dockerfile
    generate_branch_v8_17_dockerfile    ${testing_tag}          '$REVISION'         master-zh               > master/Dockerfile

    generate_docker_compose_yml         ${version_latest}       > docker-compose.yml

    generate_readme \
        ${version_8_17} \
        ${version_9_0} \
        ${version_9_1} \
        ${version_9_2} \
        ${version_9_3} \
        ${version_latest} \
        ${testing_version} \
        ${testing_tag} \
        ${testing_branch} \
        > README.md
}
