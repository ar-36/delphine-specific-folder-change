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

  name         = "edapa-adv-analy-ent-forecasting-prod-tf-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "edapa-adv-analy-ent-forecasting-prod-tf-locking"
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


####################################################################################################
# S3 Bucket for State - Current
#
# This block is temporary and allows us to retain the existing S3 bucket alongside the new bucket,
# without having to drop it from state. Once a CR to migrate has completed, we can remove this
# block and instead rely on the module call above.
####################################################################################################
resource "aws_s3_bucket" "state" {
  # checkov:skip=CKV_AWS_144:Cross-Region replication not required for a state storage bucket
  # checkov:skip=CKV2_AWS_61:Lifecycle Configuration not require for a state storage bucket
  # checkov:skip=CKV2_AWS_62:No requirement for event notifications on a state storage bucket
  # checkov:skip=CKV_AWS_145:SSE-S3 judged sufficient for a state storage bucket
  bucket = "edapa-ent-forecast-prod-tf-state-891377037249-ca-central-1"

  tags = {
    Name = "edapa-ent-forecast-prod-tf-state-891377037249-ca-central-1"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_logging" "state" {
  bucket        = aws_s3_bucket.state.id
  target_bucket = "aws-accelerator-s3-access-logs-891377037249-ca-central-1"
  target_prefix = "edapa-ent-forecast-prod-tf-state-891377037249-ca-central-1/"

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket                  = aws_s3_bucket.state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }

  lifecycle {
    ignore_changes = all
  }
}
