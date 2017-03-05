#!/bin/bash
set -e

source versions
source nginx.sh
source php.sh

prepare_dep
install_nginx