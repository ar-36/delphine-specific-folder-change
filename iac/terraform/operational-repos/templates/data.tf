# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

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

  targets = flatten([
    for repo, repo_config in var.operational_repos : {
      config = repo_config
      repo   = repo
    }
    if repo_config.create_backend
  ])

  targets_map = { for target in local.targets : target.repo => target }
}

output "targets" {
  value = local.targets_map
}
