# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

provider "github" {
  owner = "CPC-SCP"

  # If for some reason you must work with this state outside of Github Actions, i.e., locally,
  # comment out the app_auth {} line temporarily and export a PAT as GITHUB_TOKEN env var.
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
    key            = "iep-provisioner/product-iac-repos/workloads/APICPoc-infra/github/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "central-tf-state-table-449236631468-ca-central-1"
  }
}
