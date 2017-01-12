#!/bin/bash

if [[ -z "${DOCKER_USERNAME}" ]]; then
    DOCKER_USERNAME=twang2218
fi

generate_branch_dockerfile() {
    TAG=$1
    VERSION=$2
    BRANCH=$3
    cat ./template/Dockerfile.branch.template | sed "s/{TAG}/${TAG}/g; s/{VERSION}/${VERSION}/g; s/{BRANCH}/${BRANCH}/g"
}

generate_tag_dockerfile() {
    TAG=$1
    VERSION=$2
    cat ./template/Dockerfile.tag.template | sed "s/{TAG}/${TAG}/g; s/{VERSION}/${VERSION}/g;"
}

generate_docker_compose_yml() {
    TAG_LATEST=$1
    cat ./template/docker-compose.yml.template | sed "s/{TAG_LATEST}/${TAG_LATEST}/g"
}

generate_readme() {
    TAG_8_11=$1
    TAG_8_12=$2
    TAG_8_13=$3
    TAG_8_14=$4
    TAG_8_15=$5
    TAG_LATEST=$TAG_8_15
    cat ./template/README.md.template | sed \
        -e "s/{TAG_8_11}/${TAG_8_11}/g" \
        -e "s/{TAG_8_12}/${TAG_8_12}/g" \
        -e "s/{TAG_8_13}/${TAG_8_13}/g" \
        -e "s/{TAG_8_14}/${TAG_8_14}/g" \
        -e "s/{TAG_8_15}/${TAG_8_15}/g" \
        -e "s/{TAG_LATEST}/${TAG_LATEST}/g" \
        -e "/{COMPOSE_EXAMPLE}/ {r docker-compose.yml" -e "d" -e "}"
}

build_and_publish() {
    BRANCH=$1
    TAG=$2
    set -xe
    docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:${TAG}" "${BRANCH}"
    if [[ -n "${DOCKER_PASSWORD}" ]]; then
        echo "Publish image '${DOCKER_USERNAME}/gitlab-ce-zh:${TAG}' to Docker Hub ..."
        docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
        docker push "${DOCKER_USERNAME}/gitlab-ce-zh:${TAG}"
    fi
    set +xe
}

check_build_publish() {
    BRANCH=$1
    TAG=$2

    if [[ -n "${TAG}" ]]; then
        echo "Found tag ${TAG}, building ${DOCKER_USERNAME}/gitlab-ce-zh:${TAG} ..."
        build_and_publish "${BRANCH}" "${TAG}"
    elif (git show --pretty="" --name-only | grep Dockerfile | grep -q ${BRANCH}); then
        echo "${BRANCH} has been updated, rebuilding ${DOCKER_USERNAME}/gitlab-ce-zh:${BRANCH} ..."
        build_and_publish "${BRANCH}" "${BRANCH}"
    else
        echo "Nothing changed in ${BRANCH}."
    fi
}

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

    Dockerfile=$(generate_branch_dockerfile ${TAG} ${VERSION} ${BRANCH})
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:${BRANCH}" -
    echo ""
    echo "List of available images:"
    docker images ${DOCKER_USERNAME}/gitlab-ce-zh
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

    Dockerfile=$(generate_tag_dockerfile ${TAG} ${VERSION})
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:${VERSION:1}" -
    echo ""
    echo "List of available images:"
    docker images ${DOCKER_USERNAME}/gitlab-ce-zh
}

# Version related functions, such as 'generate()' are put in separate file.
source ./build-version.sh

ci() {
    env | grep TRAVIS
    if [[ -n "${TRAVIS_TAG}" ]]; then
        MINOR_VERSION=$(echo "${TRAVIS_TAG}" | cut -d'.' -f2)
        BRANCH="8.${MINOR_VERSION}"
        check_build_publish "${BRANCH}" "${TRAVIS_TAG:1}"
    elif [[ "${TRAVIS_BRANCH}" == "master" ]]; then
        check_build_publish 8.11
        check_build_publish 8.12
        check_build_publish 8.13
        check_build_publish 8.14
        check_build_publish 8.15
        check_build_publish testing
    else
        echo "Not in CI."
    fi

    if [[ -n "${DOCKER_TRIGGER_LINK}" ]]; then
        echo "Triggering the 'latest' build ..."
        curl -s -H "Content-Type: application/json" --data '{"docker_tag": "latest"}' -X POST "${DOCKER_TRIGGER_LINK}"
    fi

    docker images "${DOCKER_USERNAME}/gitlab-ce-zh"
}

run() {
    if [ "$#" != "1" ]; then
        echo "Usage: $0 run <image-tag>"
        echo ""
        echo "List of available images:"
        docker images ${DOCKER_USERNAME}/gitlab-ce-zh
        exit 1
    fi
    TAG=$1
    set -xe
    docker run -d -P ${DOCKER_USERNAME}/gitlab-ce-zh:${TAG}
    docker ps
}

main() {
    Command=$1
    shift
    case "$Command" in
        branch)     branch "$@" ;;
        tag)        tag "$@" ;;
        generate)   generate ;;
        run)        run "$@" ;;
        ci)         ci ;;
        *)          echo "Usage: $0 <branch|tag|generate|run|ci>" ;;
    esac
}

main "$@"
