module "operational_repos" {
  source = "../../../../../../tf-modules/github-repo"

  allow_auto_merge         = false
  allow_merge_commit       = true
  allow_rebase_merge       = false
  allow_squash_merge       = true
  archived                 = false
  auto_init                = false
  delete_branch_on_merge   = true
  description              = "Provisioner for EDAP workloads."
  gitignore_template       = "Terraform"
  has_discussions          = true
  has_downloads            = false
  has_issues               = false
  has_projects             = false
  has_wiki                 = false
  homepage_url             = ""
  is_template              = false
  repo_name                = "edap-provisioner"
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
  repository         = "edap-provisioner"
  use_default        = false
}

module "github_repo_teams" {
  source = "../../../../../../tf-modules/github-team-creation"

  developer_ad_group_name  = "gh-edapraw_infra-developers"
  maintainer_ad_group_name = "gh-edapraw_infra-maintainers"
  product_name             = "edap-provisioner"
  repo_name                = "edap-provisioner"
}
