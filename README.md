# Terraform For Minimal GCP Project

This is a terraform module for the creation of a minimal
[GCP project](https://cloud.google.com/storage/docs/projects). The modules assumes that you will
also be using terraform to create further project resources and creates configuration/credentials
for that purpose.

The rationale for this module is that you want to minimize the use of account level credentials
when creating infrastructure. To that end, this module does the following:

- Creates the project and attaches it to the billing account.
- Enables any services required by additional infrastrucure.
- Creates a bucket to be used to store subsequent terraform state.
  (note that the state produced by this module isn't stored there)
- Creates a project service account and retrieves it's credentials.
  All further project resources are managed with this account.

Some experience with GCP, Docker, and Terrform would be useful when using this resource.

To bootstrap your local environment ready to create one or more projects:

- [Signup for a GCP account](https://cloud.google.com/gcp), if you don't already have one. There's
  a free trial and, at time of writing, it's quite generous (credits $300 for 12 months - whichever
  finishes first).
- Retrieve your GCP account's credentials by running: 
  `./create-account-credentials.sh <gcp-account-email>` and following the instructions. The 
  credentials are saved in a volume of the container.

The `terraform.sh` script is provided to simplify the running of terraform by automatically
providing the credentials in the last step to terraform and storing any state in a docker volume.
An example of it's usage might be: `./terraform.sh <gcp-account-email> my-vm init` -  initialising
a project intended to contain a VM and storing state in a volume named `my-vm-project-tf`.

Now to create the project:
- create a folder
- copy the 
  [example files in the usage folder](https://github.com/msb/tf-gcp-project/tree/master/usage)
  into it
- update them with a descriptive project and module name

Various parameters can be overridden. For instance, if you wish to enable GCP APIs that you know
will be needed by resources in the project:

```tf
module "something_project" {
  source = "git::https://github.com/msb/tf-gcp-project.git"

  project_name    = "Something"
  additional_apis = [
    "container.googleapis.com"
  ]
}
```

See the [`variables.tf`](https://github.com/msb/tf-gcp-project/blob/master/variables.tf) for the
possible parameters. Then to deploy the run the two standard
[terraform](https://www.terraform.io/docs/index.html) commands `init` followed by `apply`.

Once the project is created you can use the `terraform.output.sh` script that wraps the terraform
`output` command and creates configuration to be used by another TF repo creating project
resources.

## Development

When developing the module it's useful to test your changes on a branch so as not to impact
existing consumers. Say, for example, that you've pushed new changes to `my-dev-branch`. You can
test these changes by using the following `source` in your module configuration:

```tf
module "cluster_project" {
  source = "git::https://github.com/msb/tf-gcp-project.git?ref=my-dev-branch"

  ...
}
```