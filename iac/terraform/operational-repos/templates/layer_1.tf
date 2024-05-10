# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {


  enterprise_account_targets = flatten([
    for repo, repo_config in var.operational_repos : [
      for account_name, account_id in repo_config.aws_account_ids : {
        account = {
          id   = account_id
          name = account_name
        }
        org_config = var.enterprise_org_config
        config     = repo_config
        repo       = repo
      }
    ]
  ])
  test_org_account_targets = flatten([
    for repo, repo_config in var.operational_repos : [
      for account_name, account_id in repo_config.test_org_aws_account_ids : {
        account = {
          id   = account_id
          name = account_name
        }
        org_config = var.test_org_config
        config     = repo_config
        repo       = repo
      }
    ]
  ])
  account_targets = concat(local.enterprise_account_targets, local.test_org_account_targets)
  account_targets_map = {
    for target in local.account_targets : "${target.repo}_${target.org_config.name}_${target.account.name}" => target
  }
  enable_alerts = {
    for k, v in local.account_targets_map :
    k => v if v.repo == "aws-ops-tooling" && lookup(var.operational_repos["aws-ops-tooling"].enable_alerts, v.account.name, false)
  }
}


resource "local_file" "iam_tf" {
  for_each = local.account_targets_map

  content = templatefile(
    "${path.module}/layer_1/iam.tftpl",
    {
      account_id                  = each.value.account.id
      account_name                = each.value.account.name
      github_org_name             = each.value.config.github_org_name
      naming_prefix               = each.value.config.naming_prefix
      repo_name                   = each.value.repo
      reusable_workflow_repo_name = each.value.config.reusable_workflow_repo_name
    }
  )

  filename = "${path.module}/../repos/${each.value.repo}/${each.value.org_config.name}/${each.value.account.name}/layer_1/iam.tf"
}

resource "local_file" "alerts_router" {
  for_each = local.enable_alerts

  content = templatefile("${path.module}/layer_1/alerts_router.tfpl",
    {
      account_id      = each.value.account.id
      autogen_warning = local.autogen_warning
      repo_name       = "aws-ops-tooling"
    }
  )
  filename = "${path.module}/../repos/aws-ops-tooling/${each.value.org_config.name}/${each.value.account.name}/layer_1/alerts_router.tf"
}

resource "local_file" "providers_tf" {
  for_each = local.account_targets_map

  content = templatefile(
    "${path.module}/layer_1/providers.tftpl",
    {
      account_id            = each.value.account.id
      account_name          = each.value.account.name
      aws_region            = each.value.config.aws_region
      exec_role_name        = each.value.config.exec_role_name
      repo_name             = each.value.repo
      operations_account_id = each.value.org_config.operations_account_id
      org_tag               = each.value.org_config.aws_organization_tag
    }
  )

  filename = "${path.module}/../repos/${each.value.repo}/${each.value.org_config.name}/${each.value.account.name}/layer_1/providers.tf"
}

resource "local_file" "repo_creation_tf" {
  for_each = var.operational_repos

  content = templatefile(
    "${path.module}/layer_1/repo_creation.tftpl",
    {
      repo_config = each.value
      repo_name   = each.key
    }
  )

  filename = "${path.module}/../repos/${each.key}/github/repo_creation.tf"
}

resource "local_file" "repo_providers_tf" {
  for_each = var.operational_repos

  content = templatefile(
    "${path.module}/layer_1/repo_providers.tftpl",
    {
      repo_config = each.value
      repo_name   = each.key
    }
  )

  filename = "${path.module}/../repos/${each.key}/github/repo_providers.tf"
}

resource "local_file" "state" {
  for_each = local.account_targets_map

  content = templatefile(
    "${path.module}/layer_1/state.tftpl",
    {
      account_id    = each.value.account.id
      account_name  = each.value.account.name
      aws_region    = each.value.config.aws_region
      naming_prefix = each.value.config.naming_prefix
      repo_name     = each.value.repo
    }
  )

  filename = "${path.module}/../repos/${each.value.repo}/${each.value.org_config.name}/${each.value.account.name}/layer_1/state.tf"
}

output "account_targets" {
  value = local.account_targets_map
}
