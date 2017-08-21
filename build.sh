#!/bin/bash

BASEDIR=$(dirname $0)

if [[ -z "${DOCKER_USERNAME}" ]]; then
    DOCKER_USERNAME=twang2218
fi

# Version related functions, such as 'generate()' are put in separate file.
# shellcheck source=./versions.sh
source $BASEDIR/versions.sh

function generate_branch_dockerfile() {
    cat ./template/Dockerfile.branch.template | sed "s:{TAG}:$1:g; s:{VERSION}:$2:g; s:{BRANCH}:$3:g"
}

function generate_branch_v8_17_dockerfile() {
    cat ./template/Dockerfile.branch.v8.17.template | sed "s:{TAG}:$1:g; s:{VERSION}:$2:g; s:{BRANCH}:$3:g"
}

function generate_tag_dockerfile() {
    cat ./template/Dockerfile.tag.template | sed "s:{TAG}:$1:g; s:{VERSION}:$2:g;"
}

function generate_tag_v8_17_dockerfile() {
    cat ./template/Dockerfile.tag.v8.17.template | sed "s:{TAG}:$1:g; s:{VERSION}:$2:g;"
}

function generate_docker_compose_yml() {
    cat ./template/docker-compose.yml.template | sed "s:{TAG_LATEST}:$1:g"
}

function generate_readme() {
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
        -e "s/{TAG_LATEST}/$1/g" \
        -e "s/{TESTING_VERSION}/$2/g" \
        -e "s/{TESTING_TAG}/$3/g" \
        -e "s/{TESTING_BRANCH}/$4/g" \
        -e "/{COMPOSE_EXAMPLE}/ {r docker-compose.yml" -e "d" -e "}"
}

function generate() {
    local version_latest=${VERSION_LATEST}
    local testing_version=${VERSION_LATEST}
    local testing_tag=${VERSION_LATEST}${APPENDIX_LATEST}
    local testing_branch=${BRANCHES_LATEST/./-}-stable-zh
    local number_of_version=${#VERSIONS[@]}

    for i in `seq 0 $(expr $number_of_version - 1)`
    do
        mkdir -p "${BRANCHES[$i]}"
        "${GENERATORS[$i]}"     "${VERSIONS[$i]}${APPENDIX[$i]}"    "v${VERSIONS[$i]}"  "v${VERSIONS[$i]}-zh"   >   "${BRANCHES[$i]}/Dockerfile"
    done
    generate_branch_v8_17_dockerfile    "${testing_tag}"          "v${testing_version}"     "${testing_branch}" >   testing/Dockerfile
    generate_docker_compose_yml         "${version_latest}"       > docker-compose.yml
    generate_readme "${version_latest}" "${testing_version}" "${testing_tag}" "${testing_branch}" > README.md
}

function build_and_publish() {
    local branch=$1
    local tag=$2
    set -xe
    docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:$tag" $branch
    if [[ -n "${DOCKER_PASSWORD}" ]]; then
        echo "Publish image '${DOCKER_USERNAME}/gitlab-ce-zh:$tag' to Docker Hub ..."
        docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
        docker push "${DOCKER_USERNAME}/gitlab-ce-zh:$tag"
    fi
    set +xe
}

function check_build_publish() {
    local branch=$1
    local tag=$2

    if [[ -n "$tag" ]]; then
        echo "Found tag $tag, building ${DOCKER_USERNAME}/gitlab-ce-zh:$tag ..."
        build_and_publish $branch $tag
    elif (git show --pretty="" --name-only | grep Dockerfile | grep -q $branch); then
        echo "$branch has been updated, rebuilding ${DOCKER_USERNAME}/gitlab-ce-zh:$branch ..."
        build_and_publish $branch $branch
    else
        echo "Nothing changed in $branch."
    fi
}

function branch() {
    if [ "$#" != "3" ]; then
        echo "Usage: $0 branch <image-tag> <version-tag> <branch>"
        echo ""
        echo "  e.g. $0 branch 9.2.0-ce.0 v9.2.0 9-2-stable-zh"
        exit 1
    fi

    local tag=$1
    local version=$2
    local branch=$3

    Dockerfile=$(generate_branch_v8_17_dockerfile $tag $version $branch)
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:$branch" -
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

    local tag=$1
    local version=$2

    Dockerfile=$(generate_tag_v8_17_dockerfile $tag $version)
    echo "$Dockerfile"
    echo "$Dockerfile" | docker build -t "${DOCKER_USERNAME}/gitlab-ce-zh:${version:1}" -
    echo ""
    echo "List of available images:"
    docker images ${DOCKER_USERNAME}/gitlab-ce-zh
}


function ci() {
    env | grep TRAVIS
    if [[ -n "${TRAVIS_TAG}" ]]; then
        local tag="${TRAVIS_TAG:1}"
        local branch="${tag%.*}"
        check_build_publish $branch $tag
    elif [[ "${TRAVIS_BRANCH}" == "master" ]]; then
        for b in ${BRANCHES[@]}; do
            check_build_publish $b
        done
        check_build_publish testing
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
    local tag=$1
    local branch=$2
    local tagDir=$BASEDIR/gitlab-$tag

    rm -rf $BRANCH_DIR
    git clone https://gitlab.com/xhang/gitlab.git $tagDir
    cd $tagDir || return 1
    git checkout $branch
}

function detect_branch_change() {
    local tag=$1
    local tagDir=$BASEDIR/gitlab-$tag

    cd $tagDir || return 2
    git remote update > /dev/null
    if ! (git status -uno | grep -q 'up-to-date') ; then
        return 0
    else
        return 1
    fi
}

function trigger_build() {
    local tag=$1
    curl --silent \
        --header "Content-Type: application/json" \
        --request POST \
        --data "{\"docker_tag\": \"$tag\"}" \
        https://registry.hub.docker.com/u/twang2218/gitlab-ce-zh/trigger/f78a6063-8c23-4997-b925-92c8093b5e83/
    echo -e "\ndone."
}

function detect_and_build() {
    local tag=$1
    if detect_branch_change $tag; then
        echo "`date`: Changes in '$tag' detected..."
        trigger_build $tag
        git pull
    # else
    #     echo "`date`: Nothing changed in '$tag'"
    fi
}

function update() {
    cd $BASEDIR || return 1
    git pull
}

function main() {
    local command=$1
    shift
    case "$command" in
        branch)     branch "$@" ;;
        tag)        tag "$@" ;;
        generate)   generate ;;
        run)        run "$@" ;;
        ci)         ci ;;
        prepare)
            prepare_branch testing  "${BRANCHES_LATEST/./-}-stable-zh"
            ;;
        detect_and_build)
            update
            detect_and_build testing
            ;;
        *)          echo "Usage: $0 <branch|tag|generate|run|ci|prepare|detect_and_build>" ;;
    esac
}

main "$@"
