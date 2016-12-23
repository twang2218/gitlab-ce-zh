#!/bin/bash

branch() {
    if [ "$#" != "3" ]; then
        echo "Usage: $0 branch <image-tag> <version-tag> <branch>"
        echo ""
        echo "  e.g. $0 branch 8.15.0-ce.0 v8.15.0 8-15-stable-zh"
        exit 1
    fi
    TAG=$1
    VERSION=$2
    BRANCH=$3

    Dockerfile=$(cat ./Dockerfile.branch.template | sed "s/{TAG}/$TAG/g; s/{VERSION}/$VERSION/g; s/{BRANCH}/$BRANCH/g")
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "gitlab-ce-zh:$BRANCH" -
    echo ""
    echo "List of available images:"
    docker images gitlab-ce-zh
}

tag() {
    if [ "$#" != "2" ]; then
        echo "Usage: $0 tag <image-tag> <version-tag>"
        echo ""
        echo "  e.g. $0 tag 8.15.0-ce.0 v8.15.0"
        exit 1
    fi
    TAG=$1
    VERSION=$2

    Dockerfile=$(cat ./Dockerfile.tag.template | sed "s/{TAG}/$TAG/g; s/{VERSION}/$VERSION/g;")
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "gitlab-ce-zh:$VERSION-zh" -
    echo ""
    echo "List of available images:"
    docker images gitlab-ce-zh
}

run() {
    if [ "$#" != "1" ]; then
        echo "Usage: $0 run <image-tag>"
        echo ""
        echo "List of available images:"
        docker images gitlab-ce-zh
        exit 1
    fi
    TAG=$1
    set -xe
    docker run -d -P gitlab-ce-zh:$TAG
    docker ps
}

main() {
    Command=$1
    shift
    case "$Command" in
        branch)     branch "$@" ;;
        tag)        tag "$@" ;;
        run)        run "$@" ;;
        *)          echo "Usage: $0 <branch|tag|run>" ;;
    esac
}

main "$@"
