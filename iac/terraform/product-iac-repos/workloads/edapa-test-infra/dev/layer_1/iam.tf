# © 2024 Amazon Web Services, Inc. or its affiliates. All Rights Reserved.

# This AWS Content is provided subject to the terms of the AWS Customer Agreement
# available at http://aws.amazon.com/agreement or other written agreement between
# Customer and either Amazon Web Services, Inc. or Amazon Web Services EMEA SARL or both.

####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

data "aws_iam_policy_document" "gha" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      identifiers = ["arn:aws:iam::220813086125:oidc-provider/token.actions.githubusercontent.com"]
      type        = "Federated"
    }

    condition {
      test     = "StringEquals"
      values   = ["sts.amazonaws.com"]
      variable = "token.actions.githubusercontent.com:aud"
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:CPC-SCP/edapa-test-infra:job_workflow_ref:CPC-SCP/iep-reusable-gha-workflows/.github/workflows/terraform-workflow.yml@refs/heads/*",
        "repo:CPC-SCP/edapa-test-infra:job_workflow_ref:CPC-SCP/iep-reusable-gha-workflows/.github/workflows/terraform-force-unlock.yml@refs/heads/*",

        "repo:CPC-SCP/edapa-test-infra:job_workflow_ref:CPC-SCP/iep-reusable-gha-workflows/.github/workflows/terraform-destroy.yml@refs/heads/*",
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
    sid       = "DenyIaCAssetChanges"
    actions   = ["*"]
    effect    = "Deny"
    resources = ["arn:aws:iam::*:role/iep-*"]
  }

  statement {
    sid = "DenyChangesToBoundaryPolicy"

    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:SetDefaultPolicyVersion"
    ]

    effect    = "Deny"
    resources = ["arn:aws:iam::*:policy/iep-permissions-boundary-policy"]
  }

  statement {
    sid = "DenyChangesToKMSKeys"

    actions = [
      "kms:PutKeyPolicy",
      "kms:ReplicateKey"
    ]

    effect    = "Deny"
    resources = ["arn:aws:kms:*:*:key/*"]
  }

  statement {
    sid = "EnforceActionsHaveBoundary"

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy"
    ]

    effect    = "Deny"
    resources = ["*"]

    condition {
      test     = "StringNotLike"
      variable = "iam:PermissionsBoundary"
      values   = ["arn:aws:iam::*:policy/iep-permissions-boundary-policy"]
    }
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
  name                 = "iep-edapa-test-infra-dev-gha-exec"
  path                 = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",

    # The following three policies are attached via AWS Config in an LZA Environment
    # We're therefore attaching them explicitly here to squash a perpetual diff
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

  ]

  # permissions_boundary = aws_iam_policy.edapa-test-infra_dev_role_permission_boundary.arn

  tags = {
    Name = "iep-edapa-test-infra-dev-gha-exec"
  }
}

