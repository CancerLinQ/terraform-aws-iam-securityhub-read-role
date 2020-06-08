# This project creates the "clq-<universe>-securityhub-read-role" role for managing AWS as a power user

# Setting up environment variables
terraform {
  required_version = "~> 0.12"
  backend "s3" {
    bucket  = "clq-terraform-account-states"
    key     = "securityhub-read-roles/terraform.tfstate"
    region  = "us-east-1"
    acl     = "bucket-owner-full-control"
    profile = "terraform"
  }
}

provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"
  profile = "default"
}

# This is needed to look up the kms_phi_encrypt_decrypt_iam_policy_arn
data "terraform_remote_state" "universe" {
  backend = "s3"
  config = {
    bucket  = "clq-terraform-account-states"
    key     = "env:/${terraform.workspace}/terraform.tfstate"
    region  = "us-east-1"
    acl     = "bucket-owner-full-control"
    profile = "terraform"
  }
}

# Attaching the kms_phi_encrypt_decrypt_iam_policy to the operator-role policy
#resource "aws_iam_role_policy_attachment" "operator_kms" {
#  policy_arn = data.terraform_remote_state.universe.outputs.kms_phi_encrypt_decrypt_iam_policy_arn
#  role       = aws_iam_role.securityhub-read-role.id
#}

# Creating AWS IAM securityhub read role
resource "aws_iam_role" "securityhub-read-role" {
  name               = "clq-${terraform.workspace}-securityhub-read-role"
  assume_role_policy = data.aws_iam_policy_document.securityhub_read_permissions.json
}

# Initializing current identity account ID
data "aws_caller_identity" "current" {
}

# Setting up authentication with Okta
data "aws_iam_policy_document" "securityhub_read_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithSAML",
    ]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:saml-provider/Okta"]
    }

    condition {
      test     = "StringLike"
      variable = "SAML:aud"

      values = [
        "https://signin.aws.amazon.com/saml",
      ]
    }
  }
}
