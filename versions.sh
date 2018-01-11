#!/bin/bash

# Only keep latest 5 version branches
# Unless there is an extra version branch for testing, such as, '-rc'
#  Zero-based array
export VERSIONS=(
    9.2.10
    9.3.11
    9.4.6
    9.5.7
    10.0.1
)

export APPENDIX=(
    '-ce.0'
    '-ce.0'
    '-ce.0'
    '-ce.0'
    '-ce.0'
)

export GENERATORS=(
    generate_tag_v8_17_dockerfile
    generate_tag_v10_dockerfile
    generate_tag_v10_dockerfile
    generate_tag_v10_dockerfile
    generate_tag_v10_dockerfile
)

export BRANCHES=($(for v in ${VERSIONS[@]}; do echo -n "${v%.*} "; done))

# should be as simple as $VERSION[-1], however, bash on Mac is old
# export VERSION_LATEST=${VERSIONS[-1]}
LATEST_INDEX=4
export VERSION_LATEST=${VERSIONS[$LATEST_INDEX]}
export BRANCHES_LATEST=${BRANCHES[$LATEST_INDEX]}
export APPENDIX_LATEST=${APPENDIX[$LATEST_INDEX]}
