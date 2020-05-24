#!/usr/bin/env bash
#
# Executes terraform in a container, storing any state/config in a volume named by the caller.

USAGE="Usage: tf-gcp-project.sh <tf-project-volume> <TF command>..."

# Exit on errors and log commands
set -xe

# Function which will die with an error message.
function die() {
    echo -e "\e[31m" $@ "\e[39m" >&2; exit 1
}

TF_PROJECT_VOLUME=$1
[ -z "${TF_PROJECT_VOLUME}" ] && die $USAGE 

shift

docker run --interactive --tty --rm \
  --volumes-from gcloud-default \
  --volume $TF_PROJECT_VOLUME-project-tf:/terraform \
  --volume $PWD:/project msb140610/terraform-runner:1.0 $@
