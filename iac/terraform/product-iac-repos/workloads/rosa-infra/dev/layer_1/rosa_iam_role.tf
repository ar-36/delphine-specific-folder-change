## IAM ROLE FOR ROSA
data "aws_iam_policy_document" "rosa-infra_dev_instance_assume_gha_role_policy" {
  ##checkov:skip=CKV_AWS_49:This is for rosa role
  ##checkov:skip=CKV_AWS_111:This is for rosa role
  ##checkov:skip=CKV_AWS_109:This is for rosa role
  ##checkov:skip=CKV_AWS_1:This is for rosa role
  ##checkov:skip=CKV2_AWS_40:This is for rosa role
  ##checkov:skip=CKV_AWS_110:This is for rosa role
  ##checkov:skip=CKV_AWS_108:This is for rosa role
  ##checkov:skip=CKV_AWS_107:This is for rosa role

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::035426313441:oidc-provider/token.actions.githubusercontent.com"]
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
        "repo:CPC-SCP/rosa-infra:job_workflow_ref:CPC-SCP/rosa-infra/.github/workflows/rosa_dev_deploy.yml@refs/heads/*",
        "repo:CPC-SCP/rosa-infra:job_workflow_ref:CPC-SCP/rosa-infra/.github/workflows/rosa_dev_configure.yml@refs/heads/*",
        "repo:CPC-SCP/rosa-infra:job_workflow_ref:CPC-SCP/rosa-infra/.github/workflows/destroy_rosa_dev.yml@refs/heads/*"
      ]
    }
  }
}

resource "aws_iam_role" "rosa-infra_dev_workload_provisioner_role" {
  # checkov:skip=CKV_AWS_274:Allow AdministratorAccess usage here because it is appropriate for usage by TF + GHA

  assume_role_policy = data.aws_iam_policy_document.rosa-infra_dev_instance_assume_gha_role_policy.json
  name               = "cap-rosa-gha-deploy"
  path               = "/"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",

    # The following three policies are attached via AWS Config in an LZA Environment
    # We're therefore attaching them explicitly here to squash a perpetual diff
    "arn:aws:iam::aws:policy/AmazonSSMDirectoryServiceAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

  ]

  tags = {
    Name = "cap-rosa-gha-deploy"
  }
}
