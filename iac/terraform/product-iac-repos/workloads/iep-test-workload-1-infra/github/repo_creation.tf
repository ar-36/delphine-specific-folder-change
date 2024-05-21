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

module "github_repo" {
  source = "../../../../../../tf-modules/github-repo"

  allow_auto_merge         = false
  allow_merge_commit       = true
  allow_rebase_merge       = true
  allow_squash_merge       = true
  archived                 = false
  auto_init                = true
  delete_branch_on_merge   = true
  description              = "Test workload IEP team uses to develop and test platform"
  gitignore_template       = "Terraform"
  has_discussions          = false
  has_downloads            = false
  has_issues               = false
  has_projects             = false
  has_wiki                 = false
  homepage_url             = "https://cpg-gpc.atlassian.net/wiki/spaces/ARCLDOCS/pages/122759154639/Infrastructure+Engineering+Platform+IEP"
  is_template              = false
  repo_name                = "iep-test-workload-1-infra"
  repository_access_level  = "none"
  template_repository_name = "terraform-gh-workload-template"
  visibility               = "internal"
  vulnerability_alerts     = true

  branch_protection_config = {

    allow_deletions                 = true
    allow_force_pushes              = true
    enforce_admins                  = false
    require_conversation_resolution = true
  }

  required_pull_request_reviews = {

    dismiss_stale_reviews          = false
    require_approving_review_count = 3
    require_code_owner_reviews     = false
    require_last_push_approval     = false
  }
}

# By default, 'job_workflow_ref' is not passed by GitHub when it makes the assumeRole call to AWS.
# For OIDC auth to work, we must explicitly set this value.
# This is done so that we can limit use of IAM credentials to a specific, pre-approved "reusable
# workflow"
resource "github_actions_repository_oidc_subject_claim_customization_template" "main" {
  include_claim_keys = ["repo", "job_workflow_ref"]
  provider           = github
  repository         = "iep-test-workload-1-infra"
  use_default        = false
}

module "github_repo_teams" {
  source = "../../../../../../tf-modules/github-team-creation"

  developer_ad_group_name  = "gh-iep-developers"
  maintainer_ad_group_name = "gh-iep-maintainers"
  product_name             = "IEPTestWorkload1"
  repo_name                = "iep-test-workload-1-infra"
}


module "github_actions_backend_dev" {
  source = "../../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "482699811241"
  aws_account_name = "dev"
  aws_region       = "ca-central-1"


  repo_name = "iep-test-workload-1-infra"
}

module "github_actions_backend_prod" {
  source = "../../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "632860535475"
  aws_account_name = "prod"
  aws_region       = "ca-central-1"

  environment_protection = true
  environment_reviewers  = [module.github_repo_teams.out.teams.maintainers.id]

  repo_name = "iep-test-workload-1-infra"
}

module "github_actions_backend_test" {
  source = "../../../../../../tf-modules/repo-iac-backend"

  aws_account_id   = "884561156600"
  aws_account_name = "test"
  aws_region       = "ca-central-1"


  repo_name = "iep-test-workload-1-infra"
}

