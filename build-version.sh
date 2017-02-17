#!/bin/bash

function generate() {
    version_8_12=8.12.13
    version_8_13=8.13.12
    version_8_14=8.14.8
    version_8_15=8.15.5
    version_8_16=8.16.3
    version_latest=${version_8_16}
    testing_version=8.16.3
    testing_tag=${testing_version}-ce.1
    testing_branch=8-16-stable-zh

    generate_tag_dockerfile     ${version_8_12}-ce.0    v${version_8_12}    v${version_8_12}-zh     > 8.12/Dockerfile
    generate_tag_dockerfile     ${version_8_13}-ce.0    v${version_8_13}    v${version_8_13}-zh     > 8.13/Dockerfile
    generate_tag_dockerfile     ${version_8_14}-ce.0    v${version_8_14}    v${version_8_14}-zh     > 8.14/Dockerfile
    generate_tag_dockerfile     ${version_8_15}-ce.0    v${version_8_15}    v${version_8_15}-zh     > 8.15/Dockerfile
    generate_tag_dockerfile     ${version_8_16}-ce.1    v${version_8_16}    v${version_8_16}-zh     > 8.16/Dockerfile
    generate_branch_dockerfile  ${testing_tag}          v${testing_version} ${testing_branch}       > testing/Dockerfile

    generate_docker_compose_yml ${version_latest} > docker-compose.yml

    generate_readme \
        ${version_8_12} \
        ${version_8_13} \
        ${version_8_14} \
        ${version_8_15} \
        ${version_8_16} \
        ${version_latest} \
        ${testing_version} \
        ${testing_tag} \
        ${testing_branch} \
        > README.md
}
