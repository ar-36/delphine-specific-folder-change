# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {
  alerts_targets             = { for k, v in local.targets_map : k => v if v.config.enable_alerts }
  domain_targets             = { for k, v in local.targets_map : k => v if length(v.config.delegated_base_domains) != 0 }
  edap_targets               = { for k, v in local.targets_map : k => v if v.config.edap_space }
  glue_targets               = { for k, v in local.targets_map : k => v if v.config.enable_glue }
  rds_targets                = { for k, v in local.targets_map : k => v if v.config.enable_rds }
  rosa_targets               = { for k, v in local.targets_map : k => v if v.config.enable_rosa }
  onprem_irsa_targets        = { for k, v in local.targets_map : k => v if v.config.enable_onprem_irsa }
  create_github_repo_targets = { for k, v in var.product_iac_repos : k => v if v.create_github_repo }
}

resource "local_file" "alerts_router" {
  for_each = local.alerts_targets

  content = templatefile("${path.module}/layer_1/alerts_router.tfpl",
    {
      autogen_warning = local.autogen_warning
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/alerts_router.tf"
}

resource "local_file" "base_domains_tf" {
  for_each = local.domain_targets

  content = templatefile(
    "${path.module}/layer_1/base_domains.tfpl",
    {
      autogen_warning  = local.autogen_warning
      base_domains     = jsonencode(each.value.config.delegated_base_domains)
      aws_account_name = each.value.environment
      aws_account_id   = lookup(var.product_iac_repos[each.value.repo]["aws_account_ids"], each.value.environment)
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/base_domains.tf"
}

resource "local_file" "edap_iam" {
  for_each = local.edap_targets

  content = templatefile(
    "${path.module}/layer_1/iam_edap.tfpl",
    {
      account_id      = lookup(var.product_iac_repos[each.value.repo]["aws_account_ids"], each.value.environment)
      autogen_warning = local.autogen_warning
      env_name        = each.value.environment
      github_org_name = lookup(var.product_iac_repos[each.value.repo], "github_org_name")
      naming_prefix   = lookup(var.product_iac_repos[each.value.repo], "naming_prefix")

      reusable_workflow_repo_name = lookup(var.product_iac_repos[each.value.repo], "reusable_workflow_repo_name")
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/iam_edap.tf"
}

resource "local_file" "glue" {
  for_each = local.glue_targets

  content = templatefile("${path.module}/layer_1/glue.tfpl",
    {
      autogen_warning = local.autogen_warning
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/glue.tf"
}

resource "local_file" "iam" {
  for_each = local.targets_map
  content = templatefile(
    "${path.module}/layer_1/iam.tfpl",
    {
      account_id                  = lookup(var.product_iac_repos[each.value.repo]["aws_account_ids"], each.value.environment)
      autogen_warning             = local.autogen_warning
      env_name                    = each.value.environment
      github_org_name             = lookup(var.product_iac_repos[each.value.repo], "github_org_name")
      is_ci_test_account          = lookup(var.product_iac_repos[each.value.repo], "is_ci_test_account", false)
      naming_prefix               = lookup(var.product_iac_repos[each.value.repo], "naming_prefix")
      repo_name                   = each.value.repo
      repo_name_mod               = each.value.repo_mod
      reusable_workflow_repo_name = lookup(var.product_iac_repos[each.value.repo], "reusable_workflow_repo_name")
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/iam.tf"
}

resource "local_file" "layer_1_providers_tf" {
  for_each = local.targets_map

  content = templatefile(
    "${path.module}/layer_1/providers.tfpl",
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
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/providers.tf"
}

resource "local_file" "onprem_irsa" {
  for_each = local.onprem_irsa_targets

  content = templatefile(
    "${path.module}/layer_1/onprem_irsa.tfpl",
    {
      autogen_warning = local.autogen_warning
      env_name        = each.value.environment
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/onprem_irsa.tf"
}

resource "local_file" "rds" {
  for_each = local.rds_targets

  content = templatefile(
    "${path.module}/layer_1/rds.tfpl",
    {
      autogen_warning = local.autogen_warning
      github_org_name = lookup(var.product_iac_repos[each.value.repo], "github_org_name")
      aws_region      = lookup(var.product_iac_repos[each.value.repo], "aws_region")
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/rds.tf"
}

resource "local_file" "repo_creation_tf" {
  for_each = local.create_github_repo_targets

  content = templatefile(
    "${path.module}/layer_1/repo_creation.tfpl",
    {
      autogen_warning = local.autogen_warning
      repo_config     = each.value
      repo_name       = each.key
    }
  )
  filename = "${path.module}/../workloads/${each.key}/github/repo_creation.tf"
}

resource "local_file" "repo_provider_tf" {
  for_each = local.create_github_repo_targets

  content = templatefile(
    "${path.module}/layer_1/repo_providers.tfpl",
    {
      autogen_warning = local.autogen_warning
      github_org_name = lookup(each.value, "github_org_name")
      repo_name       = each.key
    }
  )
  filename = "${path.module}/../workloads/${each.key}/github/repo_providers.tf"
}

resource "local_file" "rosa" {
  for_each = local.rosa_targets

  content = templatefile(
    "${path.module}/layer_1/rosa.tfpl",
    {
      autogen_warning = local.autogen_warning
      github_org_name = lookup(var.product_iac_repos[each.value.repo], "github_org_name")
      org_tower       = lookup(var.product_iac_repos[each.value.repo], "org_tower")
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/rosa.tf"
}

resource "local_file" "state" {
  for_each = local.targets_map

  content = templatefile(
    "${path.module}/layer_1/state.tfpl",
    {
      account_id                   = lookup(var.product_iac_repos[each.value.repo]["aws_account_ids"], each.value.environment)
      autogen_warning              = local.autogen_warning
      aws_region                   = lookup(var.product_iac_repos[each.value.repo], "aws_region")
      bucket_name_prefix           = "${each.value.config.workload_shortcode}-${each.value.environment}"
      enable_legacy_bucket_cleanup = lookup(var.product_iac_repos[each.value.repo], "enable_legacy_bucket_cleanup", false)
      enable_replication           = lookup(var.product_iac_repos[each.value.repo], "enable_replication", false)
      env_name                     = each.value.environment
      naming_prefix                = lookup(var.product_iac_repos[each.value.repo], "naming_prefix")
      repo_name                    = each.value.repo
    }
  )
  filename = "${path.module}/../workloads/${each.value.repo}/${each.value.environment}/layer_1/state_buckets_tables.tf"
}
