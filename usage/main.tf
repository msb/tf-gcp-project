module "example_project" {
  source = "git::https://github.com/msb/tf-gcp-project.git"

  project_name         = "Example Name"
  billing_account_name = local.billing_account_name
}
