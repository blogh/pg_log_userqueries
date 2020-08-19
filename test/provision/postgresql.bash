#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

PACKAGES=(
	sudo yum install -y bison-devel readline-devel zlib-devel openssl-devel wget
	sudo yum groupinstall -y 'Development Tools'
)

yum install --quiet -y -e 0 "${PACKAGES[@]}"

