#!/bin/bash

function generate() {
    version_8_13=8.13.12
    version_8_14=8.14.10
    version_8_15=8.15.7
    version_8_16=8.16.7
    version_8_17=8.17.3
    version_latest=${version_8_17}
    testing_version=8.17.3
    testing_tag=${testing_version}-ce.0
    testing_branch=8-17-stable-zh

    generate_tag_dockerfile         ${version_8_13}-ce.0    v${version_8_13}    v${version_8_13}-zh     > 8.13/Dockerfile
    generate_tag_dockerfile         ${version_8_14}-ce.0    v${version_8_14}    v${version_8_14}-zh     > 8.14/Dockerfile
    generate_tag_dockerfile         ${version_8_15}-ce.0    v${version_8_15}    v${version_8_15}-zh     > 8.15/Dockerfile
    generate_tag_dockerfile         ${version_8_16}-ce.0    v${version_8_16}    v${version_8_16}-zh     > 8.16/Dockerfile
    generate_tag_v17_dockerfile     ${version_8_17}-ce.0    v${version_8_17}    v${version_8_17}-zh     > 8.17/Dockerfile
    generate_branch_v17_dockerfile  ${testing_tag}          v${testing_version} ${testing_branch}       > testing/Dockerfile

    generate_docker_compose_yml ${version_latest} > docker-compose.yml

    generate_readme \
        ${version_8_13} \
        ${version_8_14} \
        ${version_8_15} \
        ${version_8_16} \
        ${version_8_17} \
        ${version_latest} \
        ${testing_version} \
        ${testing_tag} \
        ${testing_branch} \
        > README.md
}
