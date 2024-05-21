# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################


module "apigw_bootstrap" {
  # checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash:Not required as we are using an internal repository.

  depends_on = [module.apigw_logging_role]

  source = "github.com/CPC-SCP/terraform-aws-apigw.git//modules/bootstrap?ref=v0.6.1"

  enable_rosa   = true
  naming_prefix = "iep"
}

module "apigw_logging_role" {
  # checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash:Not required as we are using an internal repository.

  source = "github.com/CPC-SCP/terraform-aws-iam.git//modules/service-role?ref=v1.0.1"

  aws_service_names   = ["apigateway"]
  descriptor          = "apigw-logging"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"]
  role_name_override  = true
}

module "rosa_backend" {
  # checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash:Not required as we are using an internal repository.

  source = "github.com/CPC-SCP/terraform-aws-iam.git//modules/rosa-backend?ref=v2.0.0"

  org_tower = "devcoe"
}
