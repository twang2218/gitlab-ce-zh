#!/bin/bash

#  Zero-based array
export VERSIONS=(
    8.17.6
    9.0.10
    9.1.7
    9.2.7
    9.3.5
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
