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

variable "product_iac_repos" {
  /*

  FOR MORE INFORMATION ON WHAT THIS DATA CONSTRUCT DOES
  PLEASE REVIEW https://cpg-gpc.atlassian.net/wiki/spaces/NGI/pages/122714522886/Github+Organization+Bootstrapping+Repository
  IN PARTICULAR, THE SECTION DESCRIBING HOW TO CORRECTLY RENDER AND APPLY TEMPLATES

  */

  type = map(object({


    ####################################################################################################
    # AWS - Configuration
    ####################################################################################################
    aws_account_ids = optional(map(string), null)
    aws_region      = optional(string, "ca-central-1")

    # The delegated base domains below can be referenced from the page: https://cpg-gpc.atlassian.net/wiki/spaces/ARCLDOCS/pages/122974634266/Bootstrap+Base+Domains+for+new+accounts
    delegated_base_domains = optional(map(string), {})

    enable_alerts      = optional(bool, true)
    enable_glue        = optional(bool, false)
    enable_onprem_irsa = optional(bool, false)
    enable_rds         = optional(bool, true)
    enable_rosa        = optional(bool, true)

    # These are a temporary flags to allow state bucket co-existence, and replication, and should
    # be enabled only when required.
    enable_legacy_bucket_cleanup = optional(bool, false)
    enable_replication           = optional(bool, false)

    exec_role_name = optional(string, "iep-provisioner-gha-exec")

    # This determines which per-service CMKs are created for the workload.
    kms = optional(map(list(string)), {})

    is_ci_test_account = optional(bool, false)
    naming_prefix      = optional(string, "iep")
    org_tower          = optional(string, "cito")


    ####################################################################################################
    # GitHub - Environment Configuration
    ####################################################################################################
    environments_requiring_deploy_approval = optional(list(string), ["prod"])


    ####################################################################################################
    # GitHub - Repository Configuration
    ####################################################################################################
    allow_auto_merge               = optional(bool, false)
    allow_merge_commit             = optional(bool, true)
    allow_rebase_merge             = optional(bool, true)
    allow_squash_merge             = optional(bool, true)
    archived                       = optional(bool, false)
    auto_init                      = optional(bool, true)
    branch_protection_config       = optional(map(string), {})
    delete_branch_on_merge         = optional(bool, true)
    description                    = optional(string, "")
    github_org_name                = optional(string, "CPC-SCP")
    gitignore_template             = optional(string, "Terraform")
    has_discussions                = optional(bool, false)
    has_downloads                  = optional(bool, false)
    has_issues                     = optional(bool, false)
    has_projects                   = optional(bool, false)
    has_wiki                       = optional(bool, false)
    homepage_url                   = optional(string, "")
    is_template                    = optional(bool, false)
    provisioner_repo_name          = optional(string, "iep-provisioner")
    repository_access_level        = optional(string, "none")
    require_approving_review_count = optional(number, 2)
    required_pull_request_reviews  = optional(map(string), {})
    reusable_workflow_repo_name    = optional(string, "iep-reusable-gha-workflows")
    template_repository_name       = optional(string, "terraform-gh-workload-template")
    visibility                     = optional(string, "internal")
    vulnerability_alerts           = optional(bool, true)
    create_github_repo             = optional(bool, true)
    edap_space                     = optional(bool, false)

    # The workload name in Proper Case, used in the GitHub team description.
    workload_name = string

    # The workload name in lower-case and short-form.
    workload_shortcode = string


    ####################################################################################################
    # GitHub - Team Configuration
    ####################################################################################################
    developer_ad_group_name  = string
    maintainer_ad_group_name = string


  }))

  description = "A list of maps defining application GitHub repositories to be held under Terraform control."
  default = {
    diahub-infra = {
      aws_account_ids = {
        dev  = "725134211203"
        prod = "993638785291"
        test = "713208680458"
      }

      description             = "diahub"
      developer_ad_group_name = "gh-diahub_infra-developers"
      enable_rosa             = false
      enable_rds              = false
      homepage_url            = ""

      kms = {
        cmks = [
          "sns"
        ]
      }

      maintainer_ad_group_name     = "gh-diahub_infra-maintainers"
      workload_name                = "DIAHub"
      workload_shortcode           = "diahub"
      enable_legacy_bucket_cleanup = true

      # keys represent base domains to create, values are whether
      # that domain has been delegated yet
      #The list of available base domains is here in org-data:
      #https://github.com/CPC-SCP/terraform-aws-org-data-fetch/blob/2c2cf0886c5ac93b2420be173057b7e56075a138/tests/cfg/outputs/expected_naming_outputs_cfg.json#L30
      delegated_base_domains = {
        canada_post-internal = false
        canada_post-private  = false
      }
    }

    edap-analytics-governance-infra = {
      aws_account_ids = {
        dev = "070318300770"
      }

      description                  = "EDAP Analytics Governance account"
      developer_ad_group_name      = "gh-edapanalyticsgovernance_infra-developers"
      enable_alerts                = false
      enable_rosa                  = false
      enable_rds                   = false
      homepage_url                 = ""
      maintainer_ad_group_name     = "gh-edapanalyticsgovernance_infra-maintainers"
      workload_name                = "EDAPAnalyticsGovernance"
      workload_shortcode           = "edapa-gov"
      create_github_repo           = false
      edap_space                   = true
      enable_legacy_bucket_cleanup = true
    }

    edap-governance-infra = {
      aws_account_ids = {
        dev  = "408327317558"
        test = "485049259865"
        prod = "416446934920"
      }

      description             = "edap-governance"
      developer_ad_group_name = "gh-edapgovernance_infra-developers"
      enable_alerts           = false
      enable_rosa             = false
      enable_rds              = false
      homepage_url            = ""

      kms = {
        cmks = [
          "catalog"
        ]
      }

      maintainer_ad_group_name     = "gh-edapgovernance_infra-maintainers"
      workload_name                = "edap-governance"
      workload_shortcode           = "edap-gov"
      enable_legacy_bucket_cleanup = true
      edap_space                   = true
    }

    edap-raw-infra = {
      aws_account_ids = {
        dev  = "712948883591"
        test = "606096854338"
        prod = "488152613919"
      }

      description                  = "edap raw"
      developer_ad_group_name      = "gh-edapraw_infra-developers"
      enable_alerts                = false
      enable_rosa                  = false
      enable_rds                   = false
      homepage_url                 = ""
      maintainer_ad_group_name     = "gh-edapraw_infra-maintainers"
      workload_name                = "edap-raw"
      workload_shortcode           = "edap-raw"
      enable_legacy_bucket_cleanup = true
      edap_space                   = true

      delegated_base_domains = {
        canada_post-internal = false
      }
    }

    edapa-test-infra = {
      aws_account_ids = {
        dev  = "220813086125"
        test = "211125409189"
        prod = "730335505732"
      }

      description                  = "EDAP Analytics Test account"
      developer_ad_group_name      = "gh-edapatest_infra-maintainers"
      enable_alerts                = false
      enable_rosa                  = false
      enable_rds                   = false
      homepage_url                 = ""
      maintainer_ad_group_name     = "gh-edapatest_infra-developers"
      workload_name                = "EDAPATest"
      workload_shortcode           = "edapa-test"
      create_github_repo           = false
      edap_space                   = true
      enable_legacy_bucket_cleanup = true
    }

    edapa-adv-analy-ent-forecasting = {
      aws_account_ids = {
        prod = "891377037249"
      }

      description              = "The EDAP Analytics for Enterprise Forecasting Prod account"
      developer_ad_group_name  = ""
      enable_alerts            = false
      enable_rosa              = false
      enable_rds               = false
      homepage_url             = ""
      maintainer_ad_group_name = ""
      workload_name            = "EDAPAAdvAnalyEntForecasting"
      workload_shortcode       = "edapa-ent-forecast"
      create_github_repo       = false
      edap_space               = true
    }

    edapa-adv-analy-fraud-model = {
      aws_account_ids = {
        prod = "211125395163"
      }

      description              = "The EDAP Analytics for Fraud Modeling account"
      developer_ad_group_name  = ""
      enable_alerts            = false
      enable_rosa              = false
      enable_phz               = false
      enable_rds               = false
      homepage_url             = "",
      maintainer_ad_group_name = ""
      workload_name            = "EDAPAAdvAnalyFraudModel"
      workload_shortcode       = "edapa-fraud-model"
      create_github_repo       = false
      edap_space               = true
    }

    i360insights-infra = {
      aws_account_ids = {
        dev  = "004802276251"
        test = "527351886011"
        prod = "744659032260"
      }

      description             = "I360 Insights"
      developer_ad_group_name = "gh-i360insights_infra-developers"
      enable_rosa             = false
      enable_rds              = false
      homepage_url            = "https://canadapost.com"

      kms = {
        cmks = [
          "sns"
        ]
      }

      maintainer_ad_group_name     = "gh-i360insights_infra-maintainers"
      workload_name                = "I360Insights"
      workload_shortcode           = "i360insights"
      enable_legacy_bucket_cleanup = true
    }

    iep-test-workload-1-infra = {
      aws_account_ids = {
        dev  = "482699811241"
        test = "884561156600"
        prod = "632860535475"
      }

      description              = "Test workload IEP team uses to develop and test platform"
      developer_ad_group_name  = "gh-iep-developers"
      enable_glue              = true
      enable_rosa              = true
      enable_rds               = true
      is_ci_test_account       = true
      homepage_url             = "https://cpg-gpc.atlassian.net/wiki/spaces/ARCLDOCS/pages/122759154639/Infrastructure+Engineering+Platform+IEP"
      maintainer_ad_group_name = "gh-iep-maintainers"
      org_tower                = "archcoe"
      workload_name            = "IEPTestWorkload1"
      workload_shortcode       = "test-1"

      # This is just an example of how you can use 'branch_protection_config' and
      # 'required_pull_request_reviews' config maps to override module defaults. The module
      # defaults represent recommended settings, these are usually the opposite of recommended
      # settings.
      branch_protection_config = {
        allow_deletions                 = true
        allow_force_pushes              = true
        enforce_admins                  = false
        require_conversation_resolution = true
      }

      # This determines which per-service CMKs are created for the workload.
      kms = {
        cmks = [
          "catalog",
          "rds",
          "s3",
          "sns",
          "sqs"
        ]
      }

      required_pull_request_reviews = {
        dismiss_stale_reviews          = false
        require_approving_review_count = 3
        require_code_owner_reviews     = false
        require_last_push_approval     = false
      }

      # keys represent base domains to create, values are whether
      # that domain has been delegated yet
      delegated_base_domains = {
        canada_post-external = false
        canada_post-internal = false
        canada_post-private  = false
        innovapost-external  = false
        innovapost-internal  = false
        innovapost-private   = false
        shared-internal      = false
        shared-private       = false
      }

    }

    rosa-infra = {
      aws_account_ids = {
        dev  = "035426313441"
        test = "276378825251"
        prod = "410692821451"
      }

      description             = "Infrastructure needed to setup and support ROSA"
      developer_ad_group_name = "gh-iep-developers"
      enable_rds              = false
      enable_rosa             = false
      homepage_url            = "https://aws.amazon.com/rosa/"

      kms = {
        cmks = [
          "sns"
        ]
      }

      maintainer_ad_group_name     = "gh-iep-maintainers"
      workload_name                = "CAP"
      workload_shortcode           = "cap"
      enable_legacy_bucket_cleanup = true
    }

    stv-infra = {
      aws_account_ids = {
        dev  = "219780354720"
        test = "167884296981"
        prod = "899633399379"
      }

      description             = "Scan to Vehicle Workload"
      developer_ad_group_name = "gh-stv_infra-developers"
      enable_replication      = true
      homepage_url            = "https://cpg-gpc.atlassian.net/wiki/spaces/COOMAILPROCESSINGANDTRANSPORTATION/pages/38173214599/Scan+To+Vehicle+STV"

      kms = {
        cmks = [
          "rds",
          "sns",
        ]
      }

      maintainer_ad_group_name     = "gh-stv_infra-maintainers"
      org_tower                    = "coo"
      workload_name                = "STV"
      workload_shortcode           = "stv"
      enable_legacy_bucket_cleanup = true
      enable_onprem_irsa           = true
      enable_rosa                  = true
      # keys represent base domains to create, values are whether
      # that domain has been delegated yet
      delegated_base_domains = {
        canada_post-internal = false
        canada_post-private  = false
      }
    }

    Observability-infra = {
      aws_account_ids = {
        dev  = "533267159902"
        test = "654654332377"
        prod = "058264422760"
      }

      description                  = "The Observability account"
      developer_ad_group_name      = "gh-observability_infra-developers"
      enable_alerts                = false
      enable_rosa                  = true
      enable_rds                   = false
      homepage_url                 = ""
      maintainer_ad_group_name     = "gh-observability_infra-maintainers"
      workload_name                = "Observability-infra"
      workload_shortcode           = "Observability"
      enable_legacy_bucket_cleanup = true
      org_tower                    = "devcoe"
    }

    CAPTest-infra = {
      aws_account_ids = {
        dev  = "851725380142"
        test = "211125654669"
        prod = "730335578993"
      }

      description                  = "The Container Application Platform"
      developer_ad_group_name      = "gh-captest_infra-developers"
      enable_alerts                = false
      enable_rosa                  = true
      enable_rds                   = false
      homepage_url                 = ""
      maintainer_ad_group_name     = "gh-captest_infra-maintainers"
      workload_name                = "CAPTest"
      workload_shortcode           = "CAPTest"
      enable_legacy_bucket_cleanup = true
      enable_onprem_irsa           = true
      org_tower                    = "archcoe"

    }

    APICPoc-infra = {
      aws_account_ids = {
        dev = "533267330468"
      }

      description                  = "PoC account for APIC (Developer Program replacement)"
      developer_ad_group_name      = "gh-apicpoc_infra-developers"
      enable_alerts                = false
      enable_rosa                  = true
      enable_rds                   = false
      homepage_url                 = ""
      maintainer_ad_group_name     = "gh-apicpoc_infra-maintainers"
      workload_name                = "APICPoc"
      workload_shortcode           = "APICPoc"
      enable_legacy_bucket_cleanup = true
      enable_onprem_irsa           = true
      org_tower                    = "cco"

    }
    ACEPoc-infra = {
      aws_account_ids = {
        dev = "891377138205"
      }

      description                  = "PoC account for ACE (EDB replacement)"
      developer_ad_group_name      = "gh-acepoc_infra-developers"
      enable_alerts                = false
      enable_rosa                  = false
      enable_rds                   = false
      homepage_url                 = ""
      maintainer_ad_group_name     = "gh-acepoc_infra-maintainers"
      workload_name                = "ACEPoc"
      workload_shortcode           = "ACEPoc"
      enable_legacy_bucket_cleanup = true
      enable_onprem_irsa           = false
      org_tower                    = "cco"

    }
  }

  validation {
    condition = alltrue(flatten([
      for repo, config in var.product_iac_repos : [
        (
          config.enable_rosa
          && contains(
            [
              "archcoe",
              "cco",
              "cito",
              "coo",
              "devcoe"
            ],
            config.org_tower
          )
        )
        || !config.enable_rosa
      ]
    ]))
    error_message = <<-EOT
      If specifying 'enable_rosa', you must supply a value for 'org_tower'.

      The value for 'org_tower' should be one of the following values:

      - archcoe
      - cco
      - cito
      - coo
      - devcoe
    EOT
  }
}
