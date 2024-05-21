# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

module "kms_cmk_sns" {
  source = "github.com/CPC-SCP/terraform-aws-kms.git//modules/kms?ref=v1.0.0"

  description = "KMS key for 'sns'"
  descriptor  = "main"
  key_policy  = <<EOT
{
    "Version": "2012-10-17",
    "Id": "sns",
    "Statement": [
        {
            "Sid": "Allow full access only to the admin role utilized by the provisioner",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::884561156600:role/iep-provisioner-gha-exec"
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
                "AWS": "arn:aws:iam::884561156600:root"
            },
            "Action": [
                "kms:Describe*",
                "kms:Get*",
                "kms:List*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "kms:CallerAccount": "884561156600"
                }
            }
        },
        {
            "Sid": "Delegate use of the key by authorized account principals",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::884561156600:root"
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
                    "kms:ViaService": "sns.ca-central-1.amazonaws.com",
                    "kms:CallerAccount": "884561156600"
                }
            }
        },
        {
            "Sid": "Allow specific AWS service principals use of the key",
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "budgets.amazonaws.com",
                    "cloudwatch.amazonaws.com",
                    "events.amazonaws.com",
                    "sns.amazonaws.com"
                ]
            },
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey*"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:SourceAccount": "884561156600"
                },
                "ArnLike": {
                    "aws:SourceArn": [
                        "arn:aws:budgets::884561156600:*",
                        "arn:aws:cloudwatch:ca-central-1:884561156600:*",
                        "arn:aws:events:ca-central-1:884561156600:*",
                        "arn:aws:sns:ca-central-1:884561156600:*"
                    ]
                }
            }
        }
    ]
}
  EOT
  service     = "sns"
}
