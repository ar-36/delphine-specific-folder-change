provider "github" {
  owner = "CPC-SCP"

  # If for some reason you must work with this state outside of Github Actions, i.e., locally,
  # comment out the app_auth {} line temporarily and export a PAT as GITHUB_TOKEN env var.
  app_auth {}

}

provider "aws" {
  region = "ca-central-1"

  default_tags {
    tags = {
      cost-key    = "1386398"
      github-repo = "edap-provisioner"
      runtime-env = "prod"
    }
  }
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
    dynamodb_table = "central-tf-state-table-449236631468-ca-central-1"
    key            = "iep-provisioner/operational-repos/edap-provisioner/operations/terraform.tfstate"
    region         = "ca-central-1"
  }
}
