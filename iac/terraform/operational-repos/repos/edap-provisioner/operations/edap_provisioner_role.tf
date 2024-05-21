# custom role for edap-provisioner
data "aws_iam_policy_document" "edap_gha" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::449236631468:oidc-provider/token.actions.githubusercontent.com"]
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

resource "aws_iam_role" "edap_gha" {
  # checkov:skip=CKV_AWS_274:Allow AdministratorAccess usage here because it is appropriate for usage by TF + GHA
  assume_role_policy   = data.aws_iam_policy_document.edap_gha.json
  max_session_duration = 7200
  name                 = "edap-provisioner-gha-exec"
  path                 = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]

  tags = {
    Name = "edap-provisioner-gha-exec"
  }
}