data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  username_exceptions = join(", ", var.username_exceptions)
}

resource "aws_lambda_permission" "allow_cloudwatch_event" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.remove_inactive_accesskeys.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.key_rotate_event.arn
}

resource "aws_cloudwatch_event_rule" "key_rotate_event" {
  name                = "iamuser_accesskey_rotation"
  description         = "runs everyday"
  schedule_expression = var.event_frequency
}

resource "aws_cloudwatch_event_target" "key_rotate_event" {
  rule = aws_cloudwatch_event_rule.key_rotate_event.name
  arn  = aws_lambda_function.remove_inactive_accesskeys.arn
}

resource "aws_lambda_function" "remove_inactive_accesskeys" {

  filename         = "remove_inactive_accesskeys-cf975918-359a-4c0a-a73b-da74745c9f11.zip"
  function_name    = var.lambda_key_retire_name
  handler          = "remove_inactive_accesskeys::remove_inactive_accesskeys.Bootstrap::ExecuteFunction"
  source_code_hash = filebase64sha256("remove_inactive_accesskeys-cf975918-359a-4c0a-a73b-da74745c9f11.zip")
  memory_size      = 512
  package_type     = "Zip"
  role             = aws_iam_role.lambda_iam_key_rotation.arn
  runtime          = "dotnet6"
  timeout          = 120

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }

  environment {
    variables = {
      region                         = data.aws_region.current.name
      days_to_remove_inactive        = var.days_to_remove_inactive
      username_exceptions            = local.username_exceptions
      accesskey_rotation_lambda_name = var.lambda_name
    }
  }
}

resource "aws_lambda_function" "iam_user_rotate_accesskeys" {

  filename         = "iam_user_rotate_accesskeys-dc818e8f-36dc-4e64-8332-caaafe11ceb4.zip"
  function_name    = var.lambda_name
  handler          = "iam_user_rotate_accesskeys::iam_user_rotate_accesskeys.Bootstrap::ExecuteFunction"
  source_code_hash = filebase64sha256("iam_user_rotate_accesskeys-dc818e8f-36dc-4e64-8332-caaafe11ceb4.zip")
  memory_size      = 1024
  package_type     = "Zip"
  role             = aws_iam_role.lambda_iam_key_rotation.arn
  runtime          = "dotnet6"
  timeout          = 120

  ephemeral_storage {
    size = 512
  }

  tracing_config {
    mode = "PassThrough"
  }

  environment {
    variables = {
      region              = data.aws_region.current.name
      days                = var.days_to_rotate
      username_exceptions = local.username_exceptions
      sns_arn             = aws_sns_topic.iamuser_accesskey_rotation.arn
    }
  }
}
