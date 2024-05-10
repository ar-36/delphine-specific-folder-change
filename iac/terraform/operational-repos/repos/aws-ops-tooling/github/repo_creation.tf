# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

module "operational_repos" {
  source                        = "../../../../../../tf-modules/github-repo"

  allow_auto_merge              = false
  allow_merge_commit            = true
  allow_rebase_merge            = true
  allow_squash_merge            = true
  archived                      = false
  auto_init                     = false
  delete_branch_on_merge        = true
  description                   = "Holds IaC relating to operations tooling."
  gitignore_template            = "Terraform"
  has_discussions               = false
  has_downloads                 = true
  has_issues                    = true
  has_projects                  = true
  has_wiki                      = true
  homepage_url                  = ""
  is_template                   = false
  repo_name                     = "aws-ops-tooling"
  repository_access_level       = "none"
  template_repository_name      = ""
  visibility                    = "internal"
  vulnerability_alerts          = false


}

# By default, 'job_workflow_ref' is not passed by GitHub when it makes the assumeRole call to AWS.
# For OIDC auth to work, we must explicitly set this value.
# This is done so that we can limit use of IAM credentials to a specific, pre-approved "reusable
# workflow"
resource "github_actions_repository_oidc_subject_claim_customization_template" "main" {
  include_claim_keys = ["repo", "job_workflow_ref"]
  provider           = github
  repository         = "aws-ops-tooling"
  use_default        = false
}

module "github_repo_teams" {
  source = "../../../../../../tf-modules/github-team-creation"

  developer_ad_group_name  = ""
  maintainer_ad_group_name = ""
  product_name             = "aws-ops-tooling"
  repo_name                = "aws-ops-tooling"
}


module "github_actions_backend_audit" {
  source = "../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "022779729608"
  aws_account_name = "audit"
  aws_region       = "ca-central-1"


  repo_name = "aws-ops-tooling"
}

module "github_actions_backend_finance" {
  source = "../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "046234751755"
  aws_account_name = "finance"
  aws_region       = "ca-central-1"


  repo_name = "aws-ops-tooling"
}

module "github_actions_backend_log_archive" {
  source = "../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "110802634245"
  aws_account_name = "log_archive"
  aws_region       = "ca-central-1"


  repo_name = "aws-ops-tooling"
}

module "github_actions_backend_network" {
  source = "../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "042224974909"
  aws_account_name = "network"
  aws_region       = "ca-central-1"


  repo_name = "aws-ops-tooling"
}

module "github_actions_backend_operations" {
  source = "../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "449236631468"
  aws_account_name = "operations"
  aws_region       = "ca-central-1"


  repo_name = "aws-ops-tooling"
}

module "github_actions_backend_perimeter" {
  source = "../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "481709940714"
  aws_account_name = "perimeter"
  aws_region       = "ca-central-1"


  repo_name = "aws-ops-tooling"
}

