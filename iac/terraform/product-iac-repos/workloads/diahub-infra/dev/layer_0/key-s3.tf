# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

module "kms_cmk_s3" {
  source = "github.com/CPC-SCP/terraform-aws-kms.git//modules/kms?ref=v1.0.0"

  description = "KMS key for 's3'"
  descriptor  = "main"
  key_policy  = <<EOT
{
    "Version": "2012-10-17",
    "Id": "s3",
    "Statement": [
        {
            "Sid": "Allow full access only to the admin role utilized by the provisioner",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::725134211203:role/iep-provisioner-gha-exec"
            },
            "Action": [
                "kms:*"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Delegate read of key metadata by authorized account principals",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::725134211203:root"
            },
            "Action": [
                "kms:Describe*",
                "kms:Get*",
                "kms:List*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "725134211203"
                }
            }
        },
        {
            "Sid": "Delegate use of the key by authorized account principals",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::725134211203:root"
            },
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:GenerateDataKey*",
                "kms:ReEncrypt*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "725134211203",
                    "kms:ViaService": "s3.ca-central-1.amazonaws.com"
                }
            }
        },
        {
            "Sid": "Allow specific AWS service principals use of the key",
            "Effect": "Allow",
            "Principal": {
                "Service": "delivery.logs.amazonaws.com"
            },
            "Action": [
                "kms:Decrypt",
                "kms:DescribeKey",
                "kms:Encrypt",
                "kms:GenerateDataKey",
                "kms:GenerateDataKeyPair",
                "kms:GenerateDataKeyPairWithoutPlaintext",
                "kms:GenerateDataKeyWithoutPlaintext",
                "kms:ReEncryptFrom",
                "kms:ReEncryptTo"
            ],
            "Resource": "*"
        },
        {
            "Sid": "Configure Datamesh role access for edap-governance spaces",
            "Effect": "Deny",
            "Principal": {
                "AWS": "arn:aws:iam::408327317558:role/edap-gov-dev-datamesh-role"
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        }
    ]
}
  EOT
  service     = "s3"
}
