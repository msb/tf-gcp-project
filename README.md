# Terraform For Minimal GCP Project

This is a terraform repo that facilitates the creation of a minimal
[GCP project](https://cloud.google.com/storage/docs/projects). The script assumes that you will
also be using terraform to create further project resources and creates configuration/credentials
for that purpose.

The rationale for this repo is that you want to minimize the use of account level credentials
when creating infrastructure. To that end, this repo does the following:

- Creates the project and attaches it to the billing account.
- Enables any services required by additional infrastrucure.
- Creates a bucket to be used to store subsequent terraform state.
  (note that the state for this project isn't stored there)
- Creates a project service account and retrieve it's credentials.
  All further project resources are managed with this account.

Some experience with GCP, Docker, and Terrform would be useful when using this resource.

To bootstrap your local environment ready to create one or more projects:

- [Signup for a GCP account](https://cloud.google.com/gcp), if you don't already have one. There's
  a free trial and, at time of writing, it's quite generous (credits $300 for 12 months whichever
  finishes 1st).
- Use the `google/cloud-sdk` container to retrieve your account's credentials with the following
  command: 
  `docker run -it --name gcloud-default google/cloud-sdk gcloud auth application-default login`
  then follow the instructions. As described on 
  [Docker Hub](https://hub.docker.com/r/google/cloud-sdk), the credentials are saved in a volume of
  the container (`application-default` is required
  so that they are in a form usabled by terraform).

The `tf-gcp-project.sh` script is provided to simplify the running of terraform. An example of it's
usage might be: `./tf-gcp-project.sh my-vm init` - initialising a project intended to house a
cluster.

Then to create the project:

- Copy locals.tf.in -> locals.tf and set the project's name along with any other appropriate
  overrides.
- Run the two standard [terraform](https://www.terraform.io/docs/index.html) commands `init` and
  `apply`.
- Once the project is created you can use the `tf-gcp-project.output.sh` script that wraps the
  terraform `output` command and creates configuration to be used by another TF repo creating
  project resources.
