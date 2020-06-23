resource "aws_iam_policy" "clq_securityhub_read_policy" {
  policy = data.aws_iam_policy_document.clq_securityhub_read_policy_permissions.json
  name   = "clq-${terraform.workspace}-securityhub-read-policy"
}

data "aws_iam_policy_document" "clq_securityhub_read_policy_permissions" {

  statement {
    effect = "Allow"
    actions = [
      "securityhub:Get*",
      "securityhub:List*",
      "securityhub:Describe*",
      "guardduty:Get*",
      "guardduty:List*",
      "inspector:Describe*",
      "inspector:Get*",
      "inspector:List*",
      "inspector:Preview*",
      "sns:ListTopics",
      "access-analyzer:Get*",
      "access-analyzer:List*"
    ]
    resources = [
      "*"]
  }
}

resource "aws_iam_role_policy_attachment" "clq_securityhub_read_role_and_policy_attachment" {
  policy_arn = aws_iam_policy.clq_securityhub_read_policy.arn
  role       = aws_iam_role.securityhub-read-role.id
}
