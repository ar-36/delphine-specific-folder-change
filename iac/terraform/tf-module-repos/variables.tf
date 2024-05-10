variable "tf_module_repos" {
  description = "list of maps defining github repos to be held under terraform control"
  type = map(object({
    description                    = optional(string, "")
    homepage_url                   = optional(string, "")
    visibility                     = optional(string, "internal")
    has_issues                     = optional(bool, false)
    has_discussions                = optional(bool, false)
    has_projects                   = optional(bool, false)
    has_wiki                       = optional(bool, false)
    has_downloads                  = optional(bool, false)
    is_template                    = optional(bool, false)
    allow_auto_merge               = optional(bool, false)
    allow_merge_commit             = optional(bool, true)
    allow_squash_merge             = optional(bool, true)
    allow_rebase_merge             = optional(bool, true)
    delete_branch_on_merge         = optional(bool, true)
    gitignore_template             = optional(string, "Terraform")
    vulnerability_alerts           = optional(bool, true)
    template_repository_name       = optional(string, "terraform-gh-module-repo-template")
    archived                       = optional(bool, false)
    repository_access_level        = optional(string, "none")
    auto_init                      = optional(bool, true)
    branch_protection_config       = optional(map(string), {})
    required_pull_request_reviews  = optional(map(string), {})
    disable_required_status_checks = optional(bool, false)
  }))
  default = {
    terraform-aws-acm                 = { description = "Terraform modules for AWS Certificate Manager" },
    terraform-aws-alerts              = { description = "Terraform modules for AWS Alerts" }
    terraform-aws-apigw               = { description = "Terraform modules for AWS API Gateway" }
    terraform-aws-appflow             = { description = "Terraform modules for AWS appflow" }
    terraform-aws-athena              = { description = "Terraform modules for AWS Athena" }
    terraform-aws-batch               = { description = "Terraform modules for AWS Batch" }
    terraform-aws-cloudfront          = { description = "Terraform modules for AWS Cloudfront" }
    terraform-aws-cur                 = { description = "Terraform modules for AWS Cost Usage Report" }
    terraform-aws-dms                 = { description = "Terraform modules for AWS DMS" }
    terraform-aws-ecr                 = { description = "Terraform modules for AWS ECR" }
    terraform-aws-ecs                 = { description = "Terraform modules for AWS ECS" }
    terraform-aws-edap                = { description = "Terraform modules for EDAP data product module development" }
    terraform-aws-efs                 = { description = "Terraform modules for AWS EFS" }
    terraform-aws-eventbridge         = { description = "Terraform modules for AWS EventBridge" }
    terraform-aws-fwm-rulegroup       = { description = "Terraform modules for AWS Firewall Manager Rule Group" }
    terraform-aws-fwm-webacl          = { description = "Terraform modules for AWS Firewall Manager Web ACL" }
    terraform-aws-glue                = { description = "Terraform modules for AWS Glue" }
    terraform-aws-iam                 = { description = "Terraform modules for AWS IAM Role" }
    terraform-aws-imagebuilder        = { description = "Terraform modules for AWS ImageBuilder" }
    terraform-aws-iotcore             = { description = "Terraform modules for AWS IOT Core" }
    terraform-aws-kinesis             = { description = "Terraform modules for AWS Kinesis" }
    terraform-aws-kms                 = { description = "Terraform modules for AWS KMS", disable_required_status_checks = true }
    terraform-aws-lambda              = { description = "Terraform modules for AWS Lambda" }
    terraform-aws-lakeformation       = { description = "Terraform modules for AWS Lakeformation" }
    terraform-aws-load-balancer       = { description = "Terraform modules for AWS Load Balancer" }
    terraform-aws-mq                  = { description = "Terraform modules for AWS Amazon MQ" }
    terraform-aws-nfw                 = { description = "Terraform modules for AWS Network Firewall" }
    terraform-aws-ops-lambda          = { description = "Terraform modules for AWS Lambda module for general operations tooling use cases" }
    terraform-aws-ops-lambda-layer    = { description = "Terraform modules for AWS Lambda layer module for general operations tooling use cases" }
    terraform-aws-org-data-fetch      = { description = "Terraform modules for retrieving data from an AWS Landing Zone or NGI control parameters" }
    terraform-aws-proxybox            = { description = "Terraform modules for AWS proxy boxes", disable_required_status_checks = true }
    terraform-aws-quicksight          = { description = "Terraform modules for AWS Quicksight" }
    terraform-aws-rds                 = { description = "Terraform modules for AWS RDS" }
    terraform-aws-route53             = { description = "Terraform modules for AWS Route53", disable_required_status_checks = true }
    terraform-aws-s3                  = { description = "Terraform modules for AWS S3" }
    terraform-aws-sagemaker           = { description = "Terraform modules for AWS Sagemaker domain with VPC only" }
    terraform-aws-secretsmanager      = { description = "Terraform modules for AWS Secrets Manager" }
    terraform-aws-security-group      = { description = "Terraform modules for AWS Security Group" }
    terraform-aws-sns                 = { description = "Terraform modules for AWS SNS", disable_required_status_checks = true }
    terraform-aws-sqs                 = { description = "Terraform modules for AWS SQS" }
    terraform-aws-step-functions      = { description = "Terraform modules for AWS Step Functions" }
    terraform-gh-module-repo-template = { description = "Terraform module template repository", is_template = true, template_repository_name = "", disable_required_status_checks = true }
    terraform-gh-workload-template    = { description = "Terraform workload template repository", is_template = true, template_repository_name = "", disable_required_status_checks = true }
  }
}
