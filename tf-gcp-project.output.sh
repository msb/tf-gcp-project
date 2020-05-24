#!/usr/bin/env bash
#
# Converts the output of the terraform to:
# - The private key file of the project's service account credentials
# - A `default.tf` file (overriding the `terraform-runner` file) defining:
#   - the GCS backend
#   - the gcloud provider configured with credentials

USAGE="Usage: tf-gcp-project.output.sh <tf-volume> <output-path>"

# Exit on errors and log commands
set -e

# Function which will die with an error message.
function die() {
    echo -e "\e[31m" $@ "\e[39m" >&2; exit 1
}

TF_VOLUME=$1
[ -z "${TF_VOLUME}" ] && die $USAGE 

OUTPUT_PATH=$2
[ -z "${OUTPUT_PATH}" ] && die $USAGE 

command -v jq >/dev/null 2>&1
[ $? -eq 1 ] && die "this script requires 'jq' - please install"

# Output the SA private key file (`jq` is required to unescape the JSON)
./tf-gcp-project.sh $TF_VOLUME output -json service_account_credentials | jq -rc . \
  > $OUTPUT_PATH/service_account_credentials.json 

# Create a terrform config file that defines the "gcs" backend and the "google" provider.

STATE_BUCKET_NAME=$(./tf-gcp-project.sh $TF_VOLUME output state_bucket_name)
PROJECT_ID=$(./tf-gcp-project.sh $TF_VOLUME output project_id)

cat <<EOF >$OUTPUT_PATH/default.tf
terraform {
  backend "gcs" {
    bucket="$(echo $STATE_BUCKET_NAME | tr -d '[:space:]')"
  }
}
provider "google" {
  credentials = file("/project/service_account_credentials.json")
  project     = "$(echo $PROJECT_ID | tr -d '[:space:]')"
}
EOF
