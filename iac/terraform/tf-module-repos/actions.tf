locals {
  repos_target_ids = flatten([
    for repo, config in var.tf_module_repos :
    module.tf_module_repos[repo].out.repository.repo_id
    if !config.is_template && repo == "terraform-aws-step-functions"
  ])
  repos_target_names = toset(flatten([
    for repo, config in var.tf_module_repos :
    module.tf_module_repos[repo].out.repository.name
    if !config.is_template
  ]))
  repos_template_ids = flatten([
    for repo, config in var.tf_module_repos :
    module.tf_module_repos[repo].out.repository.repo_id
    if config.is_template
  ])

  sync_secret_name = "IEP_REPO_SYNC_APP_PEM_FILE"
}

# This secret is used by both the target and template repositories.
# Currently disabled pending additional permissions review.
# resource "github_actions_organization_secret_repositories" "main" {
#   secret_name = local.sync_secret_name

#   selected_repository_ids = concat(
#     local.repos_target_ids,
#     local.repos_template_ids,
#   )
# }

resource "github_actions_repository_oidc_subject_claim_customization_template" "main" {
  for_each = local.repos_target_names

  include_claim_keys = [
    "repo",
    "job_workflow_ref",
  ]

  repository  = each.value
  use_default = false
}
