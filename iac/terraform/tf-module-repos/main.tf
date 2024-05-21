locals {

  # This list should contain enforced status checks for repositories. The spacing between the
  # elements is intentional, and required.
  required_status_checks = [
    "terraform-module-ci / Check status",
  ]

}

module "tf_module_repos" {
  for_each = var.tf_module_repos

  source = "../../../tf-modules/github-repo"

  allow_auto_merge              = each.value.allow_auto_merge
  allow_merge_commit            = each.value.allow_merge_commit
  allow_rebase_merge            = each.value.allow_rebase_merge
  allow_squash_merge            = each.value.allow_squash_merge
  archived                      = each.value.archived
  auto_init                     = each.value.auto_init
  branch_protection_config      = each.value.branch_protection_config
  delete_branch_on_merge        = each.value.delete_branch_on_merge
  description                   = each.value.description
  gitignore_template            = each.value.gitignore_template
  has_discussions               = each.value.has_discussions
  has_downloads                 = each.value.has_downloads
  has_issues                    = each.value.has_issues
  has_projects                  = each.value.has_projects
  has_wiki                      = each.value.has_wiki
  homepage_url                  = each.value.homepage_url
  is_template                   = each.value.is_template
  repo_name                     = each.key
  repository_access_level       = each.value.repository_access_level
  required_pull_request_reviews = each.value.required_pull_request_reviews
  required_status_checks        = !each.value.disable_required_status_checks ? local.required_status_checks : null
  template_repository_name      = each.value.template_repository_name
  visibility                    = each.value.visibility
  vulnerability_alerts          = each.value.vulnerability_alerts
}

module "tf_module_repo_team_assignments" {
  for_each = var.tf_module_repos

  source = "../../../tf-modules/github-team-assignment"

  repo_name         = each.key
  is_tf_module_repo = true
}
