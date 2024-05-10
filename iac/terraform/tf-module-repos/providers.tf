provider "github" {
  owner = "CPC-SCP"
  // If for some reason you must work with this state outside of Github Actions, ie locally
  // Comment out the app_auth {} line temporarily and export a PAT as GITHUB_TOKEN env var
  app_auth {}
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "central-tf-state-449236631468-ca-central-1"
    key            = "iep-provisioner/tf-module-repos"
    region         = "ca-central-1"
    dynamodb_table = "central-tf-state-table-449236631468-ca-central-1"
  }
}
