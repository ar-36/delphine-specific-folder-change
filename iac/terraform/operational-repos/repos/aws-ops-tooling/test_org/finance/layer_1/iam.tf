# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

data "aws_iam_policy_document" "gha" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::404134631170:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:CPC-SCP/aws-ops-tooling:job_workflow_ref:CPC-SCP/iep-reusable-gha-workflows/.github/workflows/terraform-workflow.yml@refs/heads/*"
      ]
    }
  }
}

data "aws_iam_policy_document" "permissions_boundary" {
  # checkov:skip=CKV_AWS_49:This is a permissions boundary
  # checkov:skip=CKV_AWS_111:This is a permissions boundary
  # checkov:skip=CKV_AWS_109:This is a permissions boundary
  # checkov:skip=CKV_AWS_1:This is a permissions boundary
  # checkov:skip=CKV2_AWS_40:This is a permissions boundary

  statement {
    actions   = ["*"]
    resources = ["*"]
    effect    = "Allow"
    sid       = "AllowAll"
  }

  statement {
    actions   = ["*"]
    resources = ["arn:aws:iam::*:role/iep-*"]
    effect    = "Deny"
    sid       = "DenyIaCAssetChanges"
  }

  statement {
    condition {
      test     = "StringNotLike"
      variable = "iam:PermissionsBoundary"
      values   = ["arn:aws:iam::*:policy/iep-permissions-boundary-policy"]
    }

    actions = [
      "iam:PutRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:DetachRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:CreateRole",
      "iam:AttachRolePolicy"
    ]

    resources = ["*"]
    effect    = "Deny"
    sid       = "EnforceActionsHaveBoundary"
  }
}

resource "aws_iam_policy" "permissions_boundary" {
  name   = "iep-permissions-boundary-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.permissions_boundary.json
}

resource "aws_iam_role" "gha" {
  # checkov:skip=CKV_AWS_274:Allow AdministratorAccess usage here because it is appropriate for usage by TF + GHA

  assume_role_policy   = data.aws_iam_policy_document.gha.json
  max_session_duration = 7200
  name                 = "iep-aws-ops-tooling-gha-exec"
  path                 = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",

    # The following three policies are attached via AWS Config in an LZA Environment
    # We're therefore attaching them explicitly here to squash a perpetual diff
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

  ]

  tags = {
    Name = "iep-aws-ops-tooling-gha-exec"
  }
}
