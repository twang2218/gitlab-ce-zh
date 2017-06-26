#!/bin/bash

BASEDIR=$(dirname $0)

if [[ -z "${DOCKER_USERNAME}" ]]; then
    DOCKER_USERNAME=twang2218
fi

function generate_branch_dockerfile() {
    TAG=$1
    VERSION=$2
    BRANCH=$3
    cat ./template/Dockerfile.branch.template | sed "s:{TAG}:${TAG}:g; s:{VERSION}:${VERSION}:g; s:{BRANCH}:${BRANCH}:g"
}

function generate_branch_v8_17_dockerfile() {
    TAG=$1
    VERSION=$2
    BRANCH=$3
    cat ./template/Dockerfile.branch.v8.17.template | sed "s:{TAG}:${TAG}:g; s:{VERSION}:${VERSION}:g; s:{BRANCH}:${BRANCH}:g"
}

function generate_tag_dockerfile() {
    TAG=$1
    VERSION=$2
    cat ./template/Dockerfile.tag.template | sed "s:{TAG}:${TAG}:g; s:{VERSION}:${VERSION}:g;"
}

function generate_tag_v8_17_dockerfile() {
    TAG=$1
    VERSION=$2
    cat ./template/Dockerfile.tag.v8.17.template | sed "s:{TAG}:${TAG}:g; s:{VERSION}:${VERSION}:g;"
}

function generate_docker_compose_yml() {
    TAG_LATEST=$1
    cat ./template/docker-compose.yml.template | sed "s:{TAG_LATEST}:${TAG_LATEST}:g"
}

function generate_readme() {
    TAG_LATEST=$1
    TESTING_VERSION=$2
    TESTING_TAG=$3
    TESTING_BRANCH=$4
    cat ./template/README.md.template | sed \
        -e "s/{TAG_1}/${VERSIONS[0]}/g" \
        -e "s/{TAG_2}/${VERSIONS[1]}/g" \
        -e "s/{TAG_3}/${VERSIONS[2]}/g" \
        -e "s/{TAG_4}/${VERSIONS[3]}/g" \
        -e "s/{TAG_5}/${VERSIONS[4]}/g" \
        -e "s/{BRANCH_1}/${VERSIONS[0]%.*}/g" \
        -e "s/{BRANCH_2}/${VERSIONS[1]%.*}/g" \
        -e "s/{BRANCH_3}/${VERSIONS[2]%.*}/g" \
        -e "s/{BRANCH_4}/${VERSIONS[3]%.*}/g" \
        -e "s/{BRANCH_5}/${VERSIONS[4]%.*}/g" \
        -e "s/{TESTING_VERSION}/${TESTING_VERSION}/g" \
        -e "s/{TESTING_TAG}/${TESTING_TAG}/g" \
        -e "s/{TESTING_BRANCH}/${TESTING_BRANCH}/g" \
        -e "s/{TAG_LATEST}/${TAG_LATEST}/g" \
        -e "/{COMPOSE_EXAMPLE}/ {r docker-compose.yml" -e "d" -e "}"
}

function generate() {
    version_latest=${VERSIONS[4]}
    testing_version=${VERSIONS[4]}
    testing_tag=${testing_version}${APPENDIX[4]}
    testing_branch=${BRANCHES[4]/./-}-stable-zh

    for i in `seq 0 4`
    do
        "${GENERATORS[$i]}"     "${VERSIONS[$i]}${APPENDIX[$i]}"    "v${VERSIONS[$i]}"  "v${VERSIONS[$i]}-zh"   >   "${BRANCHES[$i]}/Dockerfile"
    done
    generate_branch_v8_17_dockerfile    "${testing_tag}"          "v${testing_version}"     "${testing_branch}" >   testing/Dockerfile
    generate_branch_v8_17_dockerfile    "${testing_tag}"          '$REVISION'               master-zh           >   master/Dockerfile

    generate_docker_compose_yml         "${version_latest}"       > docker-compose.yml

    generate_readme \
        "${version_latest}" \
        "${testing_version}" \
        "${testing_tag}" \
        "${testing_branch}" \
        > README.md
}

function build_and_publish() {
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

function check_build_publish() {
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

function branch() {
    if [ "$#" != "3" ]; then
        echo "Usage: $0 branch <image-tag> <version-tag> <branch>"
        echo ""
        echo "  e.g. $0 branch 9.2.0-ce.0 v9.2.0 9-2-stable-zh"
        exit 1
    fi
    TAG=$1
    VERSION=$2
    BRANCH=$3

    Dockerfile=$(generate_branch_v8_17_dockerfile ${TAG} ${VERSION} ${BRANCH})
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:${BRANCH}" -
    echo ""
    echo "List of available images:"
    docker images ${DOCKER_USERNAME}/gitlab-ce-zh
}

function tag() {
    if [ "$#" != "2" ]; then
        echo "Usage: $0 tag <image-tag> <version-tag>"
        echo ""
        echo "  e.g. $0 tag 9.2.0-ce.0 v9.2.0"
        exit 1
    fi
    TAG=$1
    VERSION=$2

    Dockerfile=$(generate_tag_v8_17_dockerfile ${TAG} ${VERSION})
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:${VERSION:1}" -
    echo ""
    echo "List of available images:"
    docker images ${DOCKER_USERNAME}/gitlab-ce-zh
}

# Version related functions, such as 'generate()' are put in separate file.
# shellcheck source=./build-version.sh
source $BASEDIR/build-version.sh

function ci() {
    env | grep TRAVIS
    if [[ -n "${TRAVIS_TAG}" ]]; then
        TAG="${TRAVIS_TAG:1}"
        MAJOR_VERSION=$(echo "${TAG}" | cut -d'.' -f1)
        MINOR_VERSION=$(echo "${TAG}" | cut -d'.' -f2)
        BRANCH="${MAJOR_VERSION}.${MINOR_VERSION}"
        check_build_publish "${BRANCH}" "${TAG}"
    elif [[ "${TRAVIS_BRANCH}" == "master" ]]; then
        for b in ${BRANCHES}; do
            check_build_publish "$b"
        done
        check_build_publish testing
        check_build_publish master
    else
        echo "Not in CI."
    fi

    if [[ -n "${DOCKER_TRIGGER_LINK}" ]]; then
        echo "Triggering the 'latest' build ..."
        set -xe
        curl -s -H "Content-Type: application/json" --data '{"docker_tag": "latest"}' -X POST "${DOCKER_TRIGGER_LINK}"
        set +xe
    fi

    docker images "${DOCKER_USERNAME}/gitlab-ce-zh"
}

function run() {
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

# Add to cron by 'crontab -e'
# */5 * * * * build.sh detect_and_build >> trigger.log 2>&1

function prepare_branch() {
    local TAG=$1
    local BRANCH=$2
    local TAG_DIR=$BASEDIR/gitlab-${TAG}

    rm -rf $BRANCH_DIR
    git clone https://gitlab.com/xhang/gitlab.git $TAG_DIR
    cd $TAG_DIR || return 1
    git checkout ${BRANCH}
}

function detect_branch_change() {
    local TAG=$1
    local TAG_DIR=$BASEDIR/gitlab-${TAG}

    cd $TAG_DIR || return 2
    git remote update > /dev/null
    if ! (git status -uno | grep -q 'up-to-date') ; then
        return 0
    else
        return 1
    fi
}

function trigger_build() {
    local TAG=$1
    curl --silent \
        --header "Content-Type: application/json" \
        --request POST \
        --data "{\"docker_tag\": \"${TAG}\"}" \
        https://registry.hub.docker.com/u/twang2218/gitlab-ce-zh/trigger/f78a6063-8c23-4997-b925-92c8093b5e83/
    echo -e "\ndone."
}

function detect_and_build() {
    local TAG=$1
    if detect_branch_change $TAG; then
        echo "`date`: Changes in '$TAG' detected..."
        trigger_build $TAG
        git pull
    # else
    #     echo "`date`: Nothing changed in '$TAG'"
    fi
}

function update() {
    cd $BASEDIR || return 1
    git pull
}

function main() {
    Command=$1
    shift
    case "$Command" in
        branch)     branch "$@" ;;
        tag)        tag "$@" ;;
        generate)   generate ;;
        run)        run "$@" ;;
        ci)         ci ;;
        prepare)
            prepare_branch testing 9-0-stable-zh
            prepare_branch master master-zh
            ;;
        detect_and_build)
            update
            detect_and_build testing
            detect_and_build master
            ;;
        *)          echo "Usage: $0 <branch|tag|generate|run|ci|prepare|detect_and_build>" ;;
    esac
}

main "$@"
