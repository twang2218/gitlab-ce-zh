#!/bin/bash

function generate() {
    version_8_11=8.11.11
    version_8_12=8.12.13
    version_8_13=8.13.10
    version_8_14=8.14.5
    version_8_15=8.15.3

    generate_branch_dockerfile  ${version_8_11}-ce.0    v${version_8_11}    8-11-stable-zh          > 8.11/Dockerfile
    generate_tag_dockerfile     ${version_8_12}-ce.0    v${version_8_12}    v${version_8_12}-zh     > 8.12/Dockerfile
    generate_tag_dockerfile     ${version_8_13}-ce.0    v${version_8_13}    v${version_8_13}-zh     > 8.13/Dockerfile
    generate_tag_dockerfile     ${version_8_14}-ce.0    v${version_8_14}    v${version_8_14}-zh     > 8.14/Dockerfile
    generate_tag_dockerfile     ${version_8_15}-ce.0    v${version_8_15}    v${version_8_15}-zh     > 8.15/Dockerfile
    generate_branch_dockerfile  ${version_8_15}-ce.0    v${version_8_15}    8-15-stable-zh          > testing/Dockerfile

    generate_docker_compose_yml ${version_8_15} > docker-compose.yml

    generate_readme \
        ${version_8_11} \
        ${version_8_12} \
        ${version_8_13} \
        ${version_8_14} \
        ${version_8_15} \
        > README.md
}
