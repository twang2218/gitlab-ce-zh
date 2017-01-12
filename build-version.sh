#!/bin/bash

function generate() {
    generate_branch_dockerfile  8.11.11-ce.0    v8.11.11    8-11-stable-zh  > 8.11/Dockerfile
    generate_tag_dockerfile     8.12.13-ce.0    v8.12.13    v8.12.13-zh     > 8.12/Dockerfile
    generate_tag_dockerfile     8.13.10-ce.0    v8.13.10    v8.13.10-zh     > 8.13/Dockerfile
    generate_tag_dockerfile     8.14.5-ce.0     v8.14.5     v8.14.5-zh      > 8.14/Dockerfile
    generate_tag_dockerfile     8.15.3-ce.0     v8.15.3     v8.15.3-zh      > 8.15/Dockerfile
    generate_branch_dockerfile  8.15.3-ce.0     v8.15.3     8-15-stable-zh  > testing/Dockerfile

    generate_docker_compose_yml 8.15.3 > docker-compose.yml

    generate_readme \
        8.11.11 \
        8.12.13 \
        8.13.10 \
        8.14.5 \
        8.15.3 \
        > README.md
}
