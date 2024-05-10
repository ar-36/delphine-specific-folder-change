# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

locals {
  autogen_warning = <<-EOT
    ####################################################################################################
    # !!! WARNING !!!
    #
    # The contents of this file are automatically generated, and will be overwritten!
    ####################################################################################################
  EOT

  # The goal of this targets local variable is to produce a data structure which includes a list
  # of all possible combinations of repository and account id.
  targets = flatten([
    for repo, repo_config in var.product_iac_repos : [
      for env_k, env_v in repo_config.aws_account_ids : {
        config      = repo_config
        environment = env_k

        # This is temporary logic to workaround an issue with ROSA accounts. Since ROSA accounts use
        # a special 'runtime-env' designation of 'rosa-' to handle lookups in org-data-fetch, we need
        # to add this to the environment from 'variables.tf'.
        # Note that we cannot modify the names in 'variables.tf' since that has an effect on the IAM
        # template which builds resource names with the account name in them, i.e., changing the
        # account name changes the resource name and results in duplicate resources.
        # The long-term solution is to remove the variables in the IAM template resource names, which
        # will require state migration.
        environment_cfg = (
          repo == "rosa-infra"
          ? "rosa-${env_k}"
          : env_k
        )

        repo = repo

        # This manipulation is required to address naming issues with the IEP Test Workload without
        # affecting other workloads.
        # For example, while the full workload name is required for some operations - repository
        # creation - the naming prefix (iep) needs to be stripped. This is to avoid resources
        # created with a prefix of 'iep-iep-', such as the GHA IAM role.
        repo_mod = (
          startswith(repo, "iep-")
          ? substr(repo, 4, -1)
          : repo
        )

      }
    ]
  ])

  targets_map = { for target in local.targets : "${target.repo}_${target.environment}" => target }
}

output "targets" {
  value = local.targets_map
}
