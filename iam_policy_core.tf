# https://docs.datadoghq.com/integrations/amazon_web_services/?tab=roledelegation#datadog-aws-iam-policy

data "aws_iam_policy_document" "core" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "DatadogCore"
    effect = "Allow"

    actions = [
      "cloudwatch:Get*",
      "cloudwatch:List*",
      "ec2:Describe*",
      "support:*",
      "tag:GetResources",
      "tag:GetTagKeys",
      "tag:GetTagValues"
    ]

    resources = ["*"]
  }
}

module "core_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = compact(concat(module.this.attributes, ["core"]))

  context = module.this.context
}

locals {
  core_count = local.enabled && contains(split(",", lower(join(",", var.integrations))), "core") ? 1 : 0
}

resource "aws_iam_policy" "core" {
  count  = local.core_count
  name   = module.core_label.id
  policy = join("", data.aws_iam_policy_document.core[*].json)
  tags   = module.core_label.tags
}

resource "aws_iam_role_policy_attachment" "core" {
  count      = local.core_count
  role       = join("", aws_iam_role.default[*].name)
  policy_arn = join("", aws_iam_policy.core[*].arn)
}
