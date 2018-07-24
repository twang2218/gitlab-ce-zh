#!/bin/bash

# Only keep latest 5 version branches
# Unless there is an extra version branch for testing, such as, '-rc'
#  Zero-based array
export VERSIONS=(
    10.5.8
    10.6.6
    10.7.6
    10.8.5
    11.0.4
)

export APPENDIX=(
    '-ce.0'
    '-ce.0'
    '-ce.0'
    '-ce.0'
    '-ce.0'
)

export TEMPLATES=(
    Dockerfile.tag.v10.1.template
    Dockerfile.tag.v10.1.template
    Dockerfile.tag.v10.1.template
    Dockerfile.tag.v10.1.template
    Dockerfile.tag.v10.1.template
)

export BRANCHES=($(for v in ${VERSIONS[@]}; do echo -n "${v%.*} "; done))

# should be as simple as $VERSION[-1], however, bash on Mac is old
# export VERSION_LATEST=${VERSIONS[-1]}
LATEST_INDEX=4
export VERSION_LATEST=${VERSIONS[$LATEST_INDEX]}
export BRANCHES_LATEST=${BRANCHES[$LATEST_INDEX]}
export APPENDIX_LATEST=${APPENDIX[$LATEST_INDEX]}

export RC_IMAGE_TAG=11.1.0-rc4.ce.0
export RC_COMMIT_UPSTREAM=v11.1.0-rc4
export RC_COMMIT_ZH=v11.1.0-rc6-zh
