#!/bin/bash

#  Zero-based array
export VERSIONS=(
    8.17.7
    9.0.12
    9.1.9
    9.2.8
    9.3.9
    9.4.0-rc3
)

export APPENDIX=(
    '-ce.0'
    '-ce.0'
    '-ce.0'
    '-ce.0'
    '-ce.0'
    '.ce.0'
)

export GENERATORS=(
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
    generate_tag_v8_17_dockerfile
)

export BRANCHES=($(for v in ${VERSIONS[@]}; do echo -n "${v%.*} "; done))

export BRANCHES_LATEST=9.3
export VERSION_LATEST=9.3.9
export APPENDIX_LATEST=-ce.0
