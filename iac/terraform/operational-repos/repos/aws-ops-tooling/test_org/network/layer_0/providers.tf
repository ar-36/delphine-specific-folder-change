# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

provider "aws" {
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::918844194960:role/iep-provisioner-gha-exec"
  }

  default_tags {
    tags = {
      aws-organization = "test-aws"
      cost-key         = "1386398"
      github-repo      = "aws-ops-tooling"
      organization     = "operations"
      # Using the ops runtime implies we do not want to use workload specific
      # resources like prefix lists which don't and should not exist in operational accounts
      runtime-env = "operations"
      workload    = "tools"
    }
  }
}

provider "aws" {
  alias  = "operations"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::660732084593:role/iep-provisioner-gha-exec"
  }

  default_tags {
    tags = {
      aws-organization = "test-aws"
      cost-key         = "1386398"
      github-repo      = "aws-ops-tooling"
      organization     = "operations"
      # Using the ops runtime implies we do not want to use workload specific
      # resources like prefix lists which don't and should not exist in operational accounts
      runtime-env = "operations"
      workload    = "tools"
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
    bucket         = "central-tf-state-660732084593-ca-central-1"
    dynamodb_table = "central-tf-state-table-660732084593-ca-central-1"
    key            = "iep-provisioner/product-iac-repos/workloads/aws-ops-tooling/network/layer_0/terraform.tfstate"
    region         = "ca-central-1"
  }
}
