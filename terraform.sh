#!/usr/bin/env bash
#
# Executes terraform in a container, storing any state/config in a volume named by the caller.

USAGE="Usage: terraform.sh <gcp-account-email> <tf-project-volume> <TF command>..."

# Exit on errors and log commands
set -xe

# Function which will die with an error message.
function die() {
    echo -e "\e[31m" $@ "\e[39m" >&2; exit 1
}

ACCOUNT_EMAIL=$1
[ -z "${ACCOUNT_EMAIL}" ] && die $USAGE

shift

TF_PROJECT_VOLUME=$1
[ -z "${TF_PROJECT_VOLUME}" ] && die $USAGE 

shift

ACCOUNT_SLUG=$(echo $ACCOUNT_EMAIL | tr A-Z a-z | sed -r 's/[^a-z0-9]+/-/g')

docker run --interactive --tty --rm \
  --volumes-from gcloud-$ACCOUNT_SLUG \
  --volume $TF_PROJECT_VOLUME-project-tf:/terraform \
  --volume $PWD:/project msb140610/terraform-runner:1.1 $@
