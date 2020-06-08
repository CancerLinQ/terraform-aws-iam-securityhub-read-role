resource "aws_iam_policy" "clq_securityhub_read_policy" {
  policy = data.aws_iam_policy_document.clq_securityhub_read_policy_permissions.json
  name   = "clq-${terraform.workspace}-securityhub-read-policy"
}

data "aws_iam_policy_document" "clq_securityhub_read_policy_permissions" {

  statement {
    effect = "Allow"
    actions = [
      "securityhub:DescribeActionTargets",
      "securityhub:DescribeHub",
      "securityhub:DescribeStandards",
      "securityhub:DescribeStandardsControls",
      "securityhub:DisableImportFindingsForProduct",
      "securityhub:GetEnabledStandards",
      "securityhub:GetFindings",
      "securityhub:GetInsightResults",
      "securityhub:GetInsights",
      "securityhub:GetMasterAccount",
      "securityhub:ListTagsForResource"
    ]
    resources = [
      "*"]
  }
}

resource "aws_iam_role_policy_attachment" "clq_securityhub_read_role_and_policy_attachment" {
  policy_arn = aws_iam_policy.clq_securityhub_read_policy.arn
  role       = aws_iam_role.securityhub-read-role.id
}
