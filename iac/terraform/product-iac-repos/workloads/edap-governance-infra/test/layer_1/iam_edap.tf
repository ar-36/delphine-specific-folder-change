####################################################################################################
# !!! WARNING !!!
#
# The contents of this file are automatically generated, and will be overwritten!
####################################################################################################

# custom role for edap-provisioner
data "aws_iam_policy_document" "edap_gha" {
  statement {
    sid     = "AssumeRoleWithWebIdentity"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::485049259865:oidc-provider/token.actions.githubusercontent.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        "repo:CPC-SCP/edap-provisioner:*"
      ]
    }
  }

  statement {
    sid     = "AssumeRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::449236631468:role/edap-provisioner-gha-exec"]
    }
  }
}

data "aws_iam_policy_document" "edap_permissions_boundary" {
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
      values   = ["arn:aws:iam::*:policy/edap-permissions-boundary-policy"]
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

  statement {
    actions = [
      "iam:SetDefaultPolicyVersion",
      "iam:DeletePolicyVersion",
      "iam:DeletePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreatePolicy"
    ]

    resources = ["arn:aws:iam::*:policy/edap-permissions-boundary-policy"]
    effect    = "Deny"
    sid       = "DenyChangesToBoundaryPolicy"
  }
}

resource "aws_iam_policy" "edap_permissions_boundary" {
  name   = "edap-permissions-boundary-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.edap_permissions_boundary.json

  lifecycle {
    ignore_changes = all
  }
}

resource "aws_iam_role" "edap_gha" {
  # checkov:skip=CKV_AWS_274:Allow AdministratorAccess usage here because it is appropriate for usage by TF + GHA

  assume_role_policy   = data.aws_iam_policy_document.edap_gha.json
  max_session_duration = 7200
  name                 = "edap-provisioner-gha-exec"
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
    Name = "edap-provisioner-gha-exec"
  }
}
