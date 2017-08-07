#!/bin/bash

# Only keep latest 5 version branches
# Unless there is an extra version branch for testing, such as, '-rc'
#  Zero-based array
export VERSIONS=(
    9.0.12
    9.1.9
    9.2.8
    9.3.9
    9.4.1
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
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
)

export BRANCHES=($(for v in ${VERSIONS[@]}; do echo -n "${v%.*} "; done))

# should be as simple as $VERSION[-1], however, bash on Mac is old
# export VERSION_LATEST=${VERSIONS[-1]}
export VERSION_LATEST=${VERSIONS[${#VERSIONS[@]}-1]}
export BRANCHES_LATEST=${VERSION_LATEST%.*}
export APPENDIX_LATEST=-ce.0
