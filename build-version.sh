#!/bin/bash

function generate() {
    version_8_15=8.15.8
    version_8_16=8.16.9
    version_8_17=8.17.5
    version_9_0=9.0.6
    version_9_1=9.1.2
    version_latest=${version_9_1}
    testing_version=${version_9_1}
    testing_tag=${testing_version}-ce.0
    testing_branch=9-1-stable-zh

    generate_tag_dockerfile             ${version_8_15}-ce.0    v${version_8_15}    v${version_8_15}-zh     > 8.15/Dockerfile
    generate_tag_dockerfile             ${version_8_16}-ce.0    v${version_8_16}    v${version_8_16}-zh     > 8.16/Dockerfile
    generate_tag_v8_17_dockerfile       ${version_8_17}-ce.0    v${version_8_17}    v${version_8_17}-zh     > 8.17/Dockerfile
    generate_tag_v8_17_dockerfile       ${version_9_0}-ce.0     v${version_9_0}     v${version_9_0}-zh      > 9.0/Dockerfile
    generate_tag_v8_17_dockerfile       ${version_9_1}-ce.0     v${version_9_1}     v${version_9_1}-zh      > 9.1/Dockerfile
    generate_branch_v8_17_dockerfile    ${testing_tag}          v${testing_version} ${testing_branch}       > testing/Dockerfile
    generate_branch_v8_17_dockerfile    ${testing_tag}          '$REVISION'         master-zh               > master/Dockerfile

    generate_docker_compose_yml         ${version_latest}       > docker-compose.yml

    generate_readme \
        ${version_8_15} \
        ${version_8_16} \
        ${version_8_17} \
        ${version_9_0} \
        ${version_9_1} \
        ${version_latest} \
        ${testing_version} \
        ${testing_tag} \
        ${testing_branch} \
        > README.md
}
