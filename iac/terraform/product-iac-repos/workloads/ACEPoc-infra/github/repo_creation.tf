# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

####################################################################################################
# GitHub Repo Creation
####################################################################################################

# aasas
module "github_repo" {
  source = "../../../../../../tf-modules/github-repo"

  allow_auto_merge         = false
  allow_merge_commit       = true
  allow_rebase_merge       = true
  allow_squash_merge       = true
  archived                 = false
  auto_init                = true
  delete_branch_on_merge   = true
  description              = "PoC account for ACE (EDB replacement)"
  gitignore_template       = "Terraform"
  has_discussions          = false
  has_downloads            = false
  has_issues               = false
  has_projects             = false
  has_wiki                 = false
  homepage_url             = ""
  is_template              = false
  repo_name                = "ACEPoc-infra"
  repository_access_level  = "none"
  template_repository_name = "terraform-gh-workload-template"
  visibility               = "internal"
  vulnerability_alerts     = true


}

# By default, 'job_workflow_ref' is not passed by GitHub when it makes the assumeRole call to AWS.
# For OIDC auth to work, we must explicitly set this value.
# This is done so that we can limit use of IAM credentials to a specific, pre-approved "reusable
# workflow"
resource "github_actions_repository_oidc_subject_claim_customization_template" "main" {
  include_claim_keys = ["repo", "job_workflow_ref"]
  provider           = github
  repository         = "ACEPoc-infra"
  use_default        = false
}

module "github_repo_teams" {
  source = "../../../../../../tf-modules/github-team-creation"

  developer_ad_group_name  = "gh-acepoc_infra-developers"
  maintainer_ad_group_name = "gh-acepoc_infra-maintainers"
  product_name             = "ACEPoc"
  repo_name                = "ACEPoc-infra"
}


module "github_actions_backend_dev" {
  source = "../../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "891377138205"
  aws_account_name = "dev"
  aws_region       = "ca-central-1"


  repo_name = "ACEPoc-infra"
}

