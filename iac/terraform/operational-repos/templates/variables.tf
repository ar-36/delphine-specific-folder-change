# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

# This variable contains the organization id that will be used by CMKs, e.g., in a condition.
# The reasons for this approach over utilizing the 'org-data-fetch' helper module are as follows:
#   1. We don't want to introduce a dependency on certain access - such as an S3 bucket - to
#      generate templates.
#   2. We want to maintain policies as a static file in source control rather than abstracting
#      their creation through a module, such as 'kms'.
variable "org_id" {
  default     = "o-zvimwmiikq"
  description = "The AWS organization id"
  type        = string
}

variable "enterprise_org_config" {
  description = "Enterprise AWS Organization specific details - do not modify"
  type        = map(string)
  default = {
    id                    = "o-zvimwmiikq"
    name                  = "enterprise"
    aws_organization_tag  = "enterprise-aws"
    operations_account_id = "449236631468"

  }
}

variable "test_org_config" {
  description = "Test AWS Organization specific details - do not modify"
  type        = map(string)
  default = {
    id                    = "o-tomh7141in"
    name                  = "test_org"
    aws_organization_tag  = "test-aws"
    operations_account_id = "660732084593"
  }
}


variable "operational_repos" {
  type = map(object({
    ####################################################################################################
    # AWS - Configuration
    ####################################################################################################
    aws_account_ids          = optional(map(string), {})
    test_org_aws_account_ids = optional(map(string), {})

    aws_region     = optional(string, "ca-central-1")
    exec_role_name = optional(string, "iep-provisioner-gha-exec")

    # This determines which per-service CMKs are created for the repository accounts.
    # Since each account linked to a repository may not require the same KMS CMKs, we need to
    # accommodate per-account keys.
    # Ideally, this would be nested within the 'aws_account_ids' map. However, due to the complex
    # nature of the nesting and limitation with the optional directive, it is necessary to split
    # the two.
    kms = optional(map(map(list(string))), {})

    naming_prefix = optional(string, "iep")


    ####################################################################################################
    # GitHub - Repository Configuration
    ####################################################################################################
    allow_auto_merge                       = optional(bool, false)
    allow_merge_commit                     = optional(bool, true)
    allow_rebase_merge                     = optional(bool, true)
    allow_squash_merge                     = optional(bool, true)
    archived                               = optional(bool, false)
    auto_init                              = optional(bool, false)
    branch_protection_config               = optional(map(string), {})
    create_backend                         = optional(bool, false)
    delete_branch_on_merge                 = optional(bool, true)
    description                            = optional(string, "")
    environments_requiring_deploy_approval = optional(list(string), [])
    github_org_name                        = optional(string, "CPC-SCP")
    gitignore_template                     = optional(string, "Terraform")
    has_discussions                        = optional(bool, false)
    has_downloads                          = optional(bool, false)
    has_issues                             = optional(bool, false)
    has_projects                           = optional(bool, false)
    has_wiki                               = optional(bool, false)
    homepage_url                           = optional(string, "")
    is_template                            = optional(bool, false)
    provisioner_repo_name                  = optional(string, "iep-provisioner")
    repository_access_level                = optional(string, "none")
    require_approving_review_count         = optional(number, 2)
    required_pull_request_reviews          = optional(map(string), {})
    reusable_workflow_repo_name            = optional(string, "iep-reusable-gha-workflows")
    template_repository_name               = optional(string, "")
    visibility                             = optional(string, "internal")
    vulnerability_alerts                   = optional(bool, false)
    product_name                           = string
    enable_alerts                          = optional(map(bool))


    ####################################################################################################
    # GitHub - Team Configuration
    ####################################################################################################
    developer_ad_group_name  = optional(string, "")
    maintainer_ad_group_name = optional(string, "")


  }))

  description = "list of maps defining application github repos to be held under terraform control"
  default = {
    aws-ops-tooling = {
      aws_account_ids = {
        audit       = "022779729608"
        finance     = "046234751755"
        log_archive = "110802634245"
        network     = "042224974909"
        operations  = "449236631468"
        perimeter   = "481709940714"
      }
      test_org_aws_account_ids = {
        audit       = "062225761148"
        finance     = "404134631170"
        log_archive = "685607284632"
        network     = "918844194960"
        operations  = "660732084593"
        perimeter   = "515306175314"
      }
      enable_alerts = {
        audit       = false
        finance     = false
        log_archive = false
        network     = true
        operations  = false
        perimeter   = true
      }

      # creates KMS keys for the services in the lists below for both
      # the enterprise and test lzas denoted by `aws-ops-tooling` and
      # `test_org_aws_account_ids` key properties respectively.
      kms = {
        cmks = {
          operations = ["sns", "s3"]
          network    = ["sns", "s3"]
        }
      }

      allow_merge_commit   = true
      allow_rebase_merge   = true
      auto_init            = false
      create_backend       = true
      description          = "Holds IaC relating to operations tooling."
      enable_replication   = true
      has_discussions      = false
      has_downloads        = true
      has_issues           = true
      has_projects         = true
      has_wiki             = true
      vulnerability_alerts = false
      product_name         = "aws-ops-tooling"
    }

    iep-dependabot-configuration-workflows = {
      allow_merge_commit       = true
      allow_rebase_merge       = false
      auto_init                = false
      description              = "Contains caller workflows for dependabot configuration"
      has_discussions          = true
      repository_access_level  = "organization"
      vulnerability_alerts     = true
      developer_ad_group_name  = "gh-iep-developers"
      maintainer_ad_group_name = "gh-iep-maintainers"
      product_name             = "iep-dependabot-configuration-workflows"
    }

    iep-reusable-gha-workflows = {
      allow_merge_commit      = true
      allow_rebase_merge      = false
      auto_init               = false
      description             = "iep-reusable-gha-workflows"
      has_discussions         = true
      repository_access_level = "organization"
      vulnerability_alerts    = true
      product_name            = "iep-reusable-gha-workflows"
    }

    edap-provisioner = {
      allow_merge_commit       = true
      allow_rebase_merge       = false
      auto_init                = false
      description              = "Provisioner for EDAP workloads."
      has_discussions          = true
      repository_access_level  = "organization"
      vulnerability_alerts     = true
      developer_ad_group_name  = "gh-edapraw_infra-developers"
      maintainer_ad_group_name = "gh-edapraw_infra-maintainers"
      product_name             = "edap-provisioner"
    }
  }
}
