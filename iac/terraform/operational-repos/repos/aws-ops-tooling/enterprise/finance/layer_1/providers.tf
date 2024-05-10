# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

provider "github" {
  owner = "CPC-SCP"

  # If for some reason you must work with this state outside of Github Actions, i.e., locally,
  # comment out the app_auth {} line temporarily and export a PAT as GITHUB_TOKEN env var.
  app_auth {}

}

provider "aws" {
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::046234751755:role/iep-provisioner-gha-exec"
  }

  default_tags {
    tags = {
      aws-organization = "enterprise-aws"
      cost-key         = "1386398"
      github-repo      = "iep-provisioner"
      runtime-env      = "operations"
      workload         = "tools"
      organization     = "operations"
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
    key            = "iep-provisioner/operational-repos/aws-ops-tooling/finance/terraform.tfstate"
    region         = "ca-central-1"
  }
}
