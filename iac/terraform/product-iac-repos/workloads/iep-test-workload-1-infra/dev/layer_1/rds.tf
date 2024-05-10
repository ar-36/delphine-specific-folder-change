# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################


module "rds_logging_role" {
  # checkov:skip=CKV_TF_1:Ensure Terraform module sources use a commit hash:Not required as we are using an internal repository.

  source = "github.com/CPC-SCP/terraform-aws-iam.git//modules/service-role?ref=v1.0.1"

  aws_service_names   = ["monitoring.rds"]
  descriptor          = "rds-logging"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"]
  role_name_override  = true
}

module "dms_logging_role" {
  source = "github.com/CPC-SCP/terraform-aws-iam.git//modules/service-role?ref=v0.14.2"

  aws_service_names = [
    "dms",
    "dms.ca-central-1",
  ]

  descriptor          = "dms-cloudwatch-logs-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonDMSCloudWatchLogsRole"]
  role_name_override  = true
}

module "dms_vpc_role" {
  source = "github.com/CPC-SCP/terraform-aws-iam.git//modules/service-role?ref=v0.14.2"

  aws_service_names = [
    "dms",
    "dms.ca-central-1",
  ]

  descriptor          = "dms-vpc-role"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonDMSVPCManagementRole"]
  role_name_override  = true
}
