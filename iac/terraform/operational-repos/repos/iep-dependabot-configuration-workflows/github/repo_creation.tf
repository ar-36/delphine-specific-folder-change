# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

module "operational_repos" {
  source = "../../../../../../tf-modules/github-repo"

  allow_auto_merge         = false
  allow_merge_commit       = true
  allow_rebase_merge       = false
  allow_squash_merge       = true
  archived                 = false
  auto_init                = false
  delete_branch_on_merge   = true
  description              = "Contains caller workflows for dependabot configuration"
  gitignore_template       = "Terraform"
  has_discussions          = true
  has_downloads            = false
  has_issues               = false
  has_projects             = false
  has_wiki                 = false
  homepage_url             = ""
  is_template              = false
  repo_name                = "iep-dependabot-configuration-workflows"
  repository_access_level  = "organization"
  template_repository_name = ""
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
  repository         = "iep-dependabot-configuration-workflows"
  use_default        = false
}

module "github_repo_teams" {
  source = "../../../../../../tf-modules/github-team-creation"

  developer_ad_group_name  = "gh-iep-developers"
  maintainer_ad_group_name = "gh-iep-maintainers"
  product_name             = "iep-dependabot-configuration-workflows"
  repo_name                = "iep-dependabot-configuration-workflows"
}


