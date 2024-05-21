# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {

  # This variable contains CMKs that are required, regardless of configuration, e.g., an S3 key
  # for the state bucket.
  kms_cmk_required = ["s3"]

  # The purpose of this variable is to provide a differentiation between key files and any
  # other Terraform files, e.g., 'provider.tf', in a workload directory.
  kms_cmk_tf_prefix = "key"

  # This list contains workloads, environments, and the keys to provision, based on configuration
  # in 'variables.tf'.
  kms_targets_configured_list = flatten([
    for repo, repo_config in var.product_iac_repos : [
      for env_k, env_v in repo_config.aws_account_ids : [
        for service in distinct(concat(local.kms_cmk_required, try(repo_config.kms.cmks, []))) : {
          environment = env_k
          repo        = repo
          service     = service
          config      = repo_config
        }
      ]
    ]
  ])

  # This list contains workloads, environments, and the keys that are currently configured.
  # This is based simply on what files are present.
  kms_targets_existing_list = flatten([
    for repo, repo_config in var.product_iac_repos : [
      for env_k, env_v in repo_config.aws_account_ids : [
        for file in fileset("../workloads/${repo}/${env_k}/kms/", "${local.kms_cmk_tf_prefix}-*.tf") : {
          environment = env_k
          repo        = repo
          service     = split("-", split(".", file)[0])[1] # 'key-sns.tf' becomes 'sns'.
          config      = repo_config
        }
      ]
    ]
  ])

  # This map contains each workload/environment/service combination. It unions the
  # configured/existing lists to ensure that even if a feature is disabled, the key remains.
  kms_targets_map = {
    for target in setunion(local.kms_targets_configured_list, local.kms_targets_existing_list)
    : "${target.repo}_${target.environment}_${target.service}" => target
  }
  governance_account_ids = merge({ "dev" = "", "test" = "", "prod" = "" }, var.product_iac_repos["edap-governance-infra"]["aws_account_ids"])
}

resource "local_file" "kms_cmk_tf" {
  for_each = local.kms_targets_map

  content = templatefile(
    "${path.module}/layer_0/key.tfpl",
    {
      autogen_warning = local.autogen_warning
      key_policy = templatefile(
        "${path.module}/layer_0/key_policies/${each.value.service}.json",
        {
          account_id            = lookup(var.product_iac_repos[each.value.repo]["aws_account_ids"], each.value.environment)
          governance_account_id = local.governance_account_ids[each.value.environment]
          env_name              = each.value.environment
          exec_role_name        = lookup(var.product_iac_repos[each.value.repo], "exec_role_name")
          edap_allow            = each.value.config.edap_space ? "Allow" : "Deny"
          org_id                = var.org_id
        }
      )
      service = each.value.service
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_0/${local.kms_cmk_tf_prefix}-${each.value.service}.tf"
}

# This is the same as the 'standard' providers file, with the critical difference being the state
# file location.
resource "local_file" "layer_0_providers" {
  for_each = local.targets_map

  content = templatefile(
    "${path.module}/layer_0/providers.tfpl",
    {
      account_id      = lookup(var.product_iac_repos[each.value.repo]["aws_account_ids"], each.value.environment)
      autogen_warning = local.autogen_warning
      aws_region      = lookup(var.product_iac_repos[each.value.repo], "aws_region")
      env_name        = each.value.environment
      env_name_cfg    = each.value.environment_cfg
      exec_role_name  = lookup(var.product_iac_repos[each.value.repo], "exec_role_name")
      repo_name       = each.value.repo
      workload        = each.value.config.workload_shortcode
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_0/providers.tf"
}
