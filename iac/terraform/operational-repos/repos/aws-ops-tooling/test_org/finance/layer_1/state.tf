# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

resource "aws_dynamodb_table" "state" {
  # checkov:skip=CKV_AWS_119:CMK encryption judged unnecessary for a DDB table which stores only locks, nothing remotely secret
  # checkov:skip=CKV_AWS_28:PITR is not required for DDB lock table

  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  name         = "aws-ops-tooling-finance-tf-locking"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "aws-ops-tooling-finance-tf-locking"
  }

  lifecycle {
    ignore_changes = all
  }
}


####################################################################################################
# S3 Bucket for State - Current
####################################################################################################
resource "aws_s3_bucket" "state" {
  # checkov:skip=CKV_AWS_144:Cross-Region replication not required for a state storage bucket
  # checkov:skip=CKV2_AWS_61:Lifecycle Configuration not require for a state storage bucket
  # checkov:skip=CKV2_AWS_62:No requirement for event notifications on a state storage bucket
  # checkov:skip=CKV_AWS_145:SSE-S3 judged sufficient for a state storage bucket
  bucket = "aws-ops-tooling-tf-state-404134631170-ca-central-1"

  tags = {
    Name = "aws-ops-tooling-tf-state-404134631170-ca-central-1"
  }

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_s3_bucket_logging" "state" {
  bucket        = aws_s3_bucket.state.id
  target_bucket = "aws-accelerator-s3-access-logs-404134631170-ca-central-1"
  target_prefix = "aws-ops-tooling-tf-state-404134631170-ca-central-1/"

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
