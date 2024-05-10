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
    role_arn = "arn:aws:iam::211125395163:role/iep-provisioner-gha-exec"
  }

  default_tags {
    tags = {
      aws-organization = "enterprise-aws"
      cost-key         = "1386398"
      github-repo      = "edapa-adv-analy-fraud-model"
      organization     = "ccoe"
      runtime-env      = "prod"
      workload         = "edapa-fraud-model"
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
      aws-organization = "enterprise-aws"
      cost-key         = "1386398"
      github-repo      = "edapa-adv-analy-fraud-model"
      organization     = "ccoe"
      runtime-env      = "prod"
      workload         = "edapa-fraud-model"
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
    key            = "iep-provisioner/product-iac-repos/workloads/edapa-adv-analy-fraud-model/prod/kms/terraform.tfstate"
    region         = "ca-central-1"
  }
}
