# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################


resource "aws_dynamodb_table" "state" {
  # checkov:skip=CKV_AWS_119:CMK encryption judged unnecessary for a DDB table which stores only locks, nothing remotely secret
  # checkov:skip=CKV_AWS_28:PITR is not required for DDB lock table

  name         = "rosa-infra-dev-tf-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "rosa-infra-dev-tf-locking"
  }

  lifecycle {
    ignore_changes = all
  }
}


####################################################################################################
# S3 Bucket for State - New
####################################################################################################
module "state_bucket" {
  source = "github.com/CPC-SCP/terraform-aws-s3.git//modules/s3?ref=v0.13.0"

  descriptor = "tf-state"
}


