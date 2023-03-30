resource "aws_sns_topic" "iamuser_accesskey_rotation" {
  name = "iamuser_accesskey_rotation"
}

#if sns_alert_email contains value, then the count is for this resource equals total emails listed.
resource "aws_sns_topic_subscription" "accesskey_rotation_email_sub" {
  count     = length(var.sns_alert_emails)
  topic_arn = aws_sns_topic.iamuser_accesskey_rotation.arn
  protocol  = "email"
  endpoint  = var.sns_alert_emails[count.index]
}

#SNS topic and subscription role/polcies
resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.iamuser_accesskey_rotation.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  policy_id = "user_accesskey_rotation_default_policy_ID"

  statement {
    actions = [
      "SNS:GetTopicAttributes",
      "SNS:SetTopicAttributes",
      "SNS:AddPermission",
      "SNS:Subscribe",
      "SNS:Publish",
      "SNS:Receive"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.iamuser_accesskey_rotation.arn,
    ]
  }
}
