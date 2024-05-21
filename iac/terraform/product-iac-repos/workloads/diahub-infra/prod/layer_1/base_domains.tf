# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

# Base domains for workloads
locals {
  selected_base_domains = { "canada_post-internal" : "false", "canada_post-private" : "false" }
  # dedupe to deal with e.g. innovapost external/internal being the same domain
  unique_base_domains = toset([
    for domain, delegated in local.selected_base_domains : [module.cfg.naming.workload_base_domain_names[domain], delegated]
  ])
  base_domains        = { for domain_info in local.unique_base_domains : domain_info[0] => tobool(domain_info[1]) }
  private_base_domain = module.cfg.naming.company_base_domains.aws_cpggpc_ca.domain
}

module "cfg" {
  # checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash:Not required.
  source     = "github.com/CPC-SCP/terraform-aws-org-data-fetch.git//modules/cfg?ref=v1.0.2"
  descriptor = "provisioner"
}

module "private_hosted_zone" {
  # there should only ever be one of these given the toset() de-dupe in locals above
  for_each       = { for domain, spec in module.public_hosted_zones : domain => true if strcontains(domain, local.private_base_domain) }
  source         = "github.com/CPC-SCP/terraform-aws-route53.git//modules/private-zones?ref=v1.0.3"
  public_zone_id = module.public_hosted_zones[each.key].name_servers.zone_id
}

module "public_hosted_zones" {
  # checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash:Not required.
  for_each = local.base_domains

  source              = "github.com/CPC-SCP/terraform-aws-route53.git//modules/public-zones?ref=v1.0.3"
  domain              = each.key
  domain_is_delegated = each.value
}

data "aws_ssm_parameter" "publish_function" {
  provider = aws.operations
  name     = "/cfg/writer/operations/publisher/function_name"
}

resource "aws_lambda_invocation" "publish_delegation_request" {
  for_each      = local.base_domains
  provider      = aws.operations
  function_name = data.aws_ssm_parameter.publish_function.value

  input = jsonencode({
    payload = jsonencode(
      {
        payload = {
          name_servers = module.public_hosted_zones[each.key].name_servers
          domain       = each.key
        }

        path = "domains/delegations/${each.key}.json"
      }
    )
    }
  )
}

resource "aws_lambda_invocation" "publish_phz_id" {
  for_each = { for domain, spec in module.private_hosted_zone : domain => true }

  provider      = aws.operations
  function_name = data.aws_ssm_parameter.publish_function.value

  input = jsonencode({
    payload = jsonencode(
      {
        payload = {
          zone_info = module.private_hosted_zone
          vpc       = "prod"
        }

        path = "phz/authorizations/993638785291.json"
      }
    )
    }
  )
}
