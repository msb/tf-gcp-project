#!/usr/bin/env bash
#
# Executes terraform in a container, storing any state/config in a volume named by the caller.

USAGE="Usage: terraform.sh <gcp-account-email> <tf-project-volume> <TF command>..."

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

# Exit on errors and log commands
set -xe

ACCOUNT_SLUG=$(echo $ACCOUNT_EMAIL | tr A-Z a-z | sed -r 's/[^a-z0-9]+/-/g')

VOLUME=$TF_PROJECT_VOLUME-project-tf

docker run --interactive --tty --rm \
  --volumes-from gcloud-$ACCOUNT_SLUG \
  --volume $VOLUME:/terraform \
  --volume $PWD:/project msb140610/terraform-runner:1.1 $@

# If DOCKER_VOLUME_BACKUPS is set, then backup the volume.
# To restore follow: https://hub.docker.com/r/loomchild/volume-backup
if [ -n "${DOCKER_VOLUME_BACKUPS}" ]
  then
	docker run --rm --volume $VOLUME:/volume --volume $DOCKER_VOLUME_BACKUPS:/backup \
  loomchild/volume-backup backup docker-volume-$VOLUME
fi
