# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {
  # This variable contains CMKs that are required, regardless of configuration, e.g., an S3 key
  # for the state bucket.
  kms_cmk_required = []

  # The purpose of this variable is to provide a differentiation between key files and any
  # other Terraform files, e.g., 'provider.tf', in a workload directory.
  kms_cmk_tf_prefix = "key"

  # This list contains workloads, environments, and the keys to provision, based on configuration
  # in 'variables.tf'.
  enterprise_kms_targets_configured_list = flatten([
    for repo, repo_config in var.operational_repos : [
      for account_name, account_id in repo_config.aws_account_ids : [
        for service in(
          distinct(concat(
            local.kms_cmk_required,
            try(repo_config.kms.cmks[account_name], [])
          ))
        )
        : {
          account = {
            id   = account_id
            name = account_name
          }
          org_config = var.enterprise_org_config
          repo       = repo
          service    = service
        }
      ]
    ]
  ])
  test_org_kms_targets_configured_list = flatten([
    for repo, repo_config in var.operational_repos : [
      for account_name, account_id in repo_config.test_org_aws_account_ids : [
        for service in(
          distinct(concat(
            local.kms_cmk_required,
            try(repo_config.kms.cmks[account_name], [])
          ))
        )
        : {
          account = {
            id   = account_id
            name = account_name
          }
          org_config = var.test_org_config
          repo       = repo
          service    = service
        }
      ]
    ]
  ])
  kms_targets_configured_list = concat(local.enterprise_kms_targets_configured_list, local.test_org_kms_targets_configured_list)

  # This list contains workloads, environments, and the keys that are currently configured.
  # This is based simply on what files are present.
  enterprise_kms_targets_existing_list = flatten([
    for repo, repo_config in var.operational_repos : [
      for account_name, account_id in repo_config.aws_account_ids : [
        for file in fileset("../repos/${repo}/${var.enterprise_org_config.name}/${account_name}/layer_0/", "${local.kms_cmk_tf_prefix}-*.tf") : {
          account = {
            id   = account_id
            name = account_name
          }
          org_config = var.enterprise_org_config
          repo       = repo
          service    = split("-", split(".", file)[0])[1] # 'key-sns.tf' becomes 'sns'.
        }
      ]
    ]
  ])
  test_org_kms_targets_existing_list = flatten([
    for repo, repo_config in var.operational_repos : [
      for account_name, account_id in repo_config.test_org_aws_account_ids : [
        for file in fileset("../repos/${repo}/${var.test_org_config.name}/${account_name}/layer_0/", "${local.kms_cmk_tf_prefix}-*.tf") : {
          account = {
            id   = account_id
            name = account_name
          }
          org_config = var.test_org_config
          repo       = repo
          service    = split("-", split(".", file)[0])[1] # 'key-sns.tf' becomes 'sns'.
        }
      ]
    ]
  ])
  kms_targets_existing_list = concat(local.enterprise_kms_targets_existing_list, local.test_org_kms_targets_existing_list)

  # This map contains each workload/environment/service combination. It unions the
  # configured/existing lists to ensure that even if a feature is disabled, the key remains.
  kms_targets_map = {
    for target in setunion(local.kms_targets_configured_list, local.kms_targets_existing_list)
    : "${target.repo}_${target.org_config.name}_${target.account.name}_${target.service}" => target
  }
}

resource "local_file" "kms_cmk_tf" {
  for_each = local.kms_targets_map

  content = templatefile(
    "${path.module}/layer_0/key.tftpl",
    {
      autogen_warning = local.autogen_warning
      key_policy = templatefile(
        "${path.module}/layer_0/key_policies/${each.value.service}.json",
        {
          account_id     = each.value.account.id
          exec_role_name = lookup(var.operational_repos[each.value.repo], "exec_role_name")
          org_id         = each.value.org_config.id
        }
      )
      service = each.value.service
    }
  )
  filename = "${path.module}/../repos/${each.value.repo}/${each.value.org_config.name}/${each.value.account.name}/layer_0/${local.kms_cmk_tf_prefix}-${each.value.service}.tf"
}

# This is the same as the 'standard' providers file, with the critical difference being the state
# file location.
resource "local_file" "layer_0_providers" {
  for_each = local.kms_targets_map
  content = templatefile(
    "${path.module}/layer_0/providers.tfpl",
    {
      account_id            = each.value.account.id
      account_name          = each.value.account.name
      autogen_warning       = local.autogen_warning
      aws_region            = lookup(var.operational_repos[each.value.repo], "aws_region")
      exec_role_name        = lookup(var.operational_repos[each.value.repo], "exec_role_name")
      repo_name             = each.value.repo
      operations_account_id = each.value.org_config.operations_account_id
      org_tag               = each.value.org_config.aws_organization_tag
    }
  )
  filename = "${path.module}/../repos/${each.value.repo}/${each.value.org_config.name}/${each.value.account.name}/layer_0/providers.tf"
}

output "kms_targets" {
  value = local.kms_targets_map
}
