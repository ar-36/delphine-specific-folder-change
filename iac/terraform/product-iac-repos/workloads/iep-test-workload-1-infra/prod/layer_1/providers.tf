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
    role_arn = "arn:aws:iam::632860535475:role/iep-provisioner-gha-exec"
  }

  default_tags {
    tags = {
      workload         = "test-1"
      runtime-env      = "prod"
      cost-key         = "1386398"
      github-repo      = "iep-test-workload-1-infra"
      aws-organization = "enterprise-aws"
      organization     = "ccoe"
    }
  }
}

provider "aws" {
  alias  = "operations"
  region = "ca-central-1"

  assume_role {
    role_arn = "arn:aws:iam::449236631468:role/iep-provisioner-gha-exec"
  }

  default_tags {
    tags = {
      workload         = "test-1"
      runtime-env      = "prod"
      cost-key         = "1386398"
      github-repo      = "iep-test-workload-1-infra"
      aws-organization = "enterprise-aws"
      organization     = "ccoe"
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
    key            = "iep-provisioner/product-iac-repos/workloads/iep-test-workload-1-infra/prod/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "central-tf-state-table-449236631468-ca-central-1"
  }
}
