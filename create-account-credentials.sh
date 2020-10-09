#!/usr/bin/env bash
#
# Uses the `google/cloud-sdk` container to retrieve your GCP account's credentials as described on
# [Docker Hub](https://hub.docker.com/r/google/cloud-sdk). The credentials are saved in a volume of
# the container to be use downstream.

USAGE="Usage: create-account-credentials <gcp-account-email>"

# Function which will die with an error message.
function die() {
    echo -e "\e[31m" $@ "\e[39m" >&2; exit 1
}

ACCOUNT_EMAIL=$1
[ -z "${ACCOUNT_EMAIL}" ] && die $USAGE

shift

ACCOUNT_SLUG=$(echo $ACCOUNT_EMAIL | tr A-Z a-z | sed -r 's/[^a-z0-9]+/-/g')

# Exit on errors and log commands
set -xe

docker run --interactive --tty --name gcloud-$ACCOUNT_SLUG \
   google/cloud-sdk gcloud auth application-default login
