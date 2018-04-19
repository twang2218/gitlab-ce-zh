#!/bin/bash

# Only keep latest 5 version branches
# Unless there is an extra version branch for testing, such as, '-rc'
#  Zero-based array
export VERSIONS=(
    10.2.8
    10.3.9
    10.4.7
    10.5.7
    10.6.3
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
