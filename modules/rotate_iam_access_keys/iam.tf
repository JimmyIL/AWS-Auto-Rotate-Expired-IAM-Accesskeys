resource "aws_iam_role_policy_attachment" "key_rotation" {
  role       = aws_iam_role.lambda_iam_key_rotation.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda_key_rotation.arn
}

resource "aws_iam_role_policy_attachment" "secret_key_rotation" {
  role       = aws_iam_role.lambda_iam_key_rotation.name
  policy_arn = aws_iam_policy.lambda_secrets_user_accesskey_rotation.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logging" {
  role       = aws_iam_role.lambda_iam_key_rotation.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "lambda_iam_key_rotation" {
  name               = "lambda_iam_key_rotation"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["lambda.amazonaws.com", "events.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "iam_policy_for_lambda_key_rotation" {
  name        = "iam_policy_for_lambda_iam_key_rotation"
  description = "IAM Policy for for using Lambda to rotate iam accesskeys"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iam:DeleteAccessKey",
        "iam:DeleteServiceSpecificCredential",
        "iam:GenerateCredentialReport",
        "iam:GenerateServiceLastAccessedDetails",
        "iam:GetAccessKeyLastUsed",
        "iam:GetCredentialReport",
        "iam:GetGroup",
        "iam:GetLoginProfile",
        "iam:GetRole",
        "iam:GetUser",
        "iam:CreateAccessKey",
        "iam:GetUserPolicy",
        "iam:ListAccessKeys",
        "iam:ListGroupsForUser",
        "iam:ListMFADevices",
        "iam:ListPolicies",
        "iam:ListRolePolicies",
        "iam:ListRoles",
        "iam:ListServiceSpecificCredentials",
        "iam:ListUserPolicies",
        "iam:ListUserTags",
        "iam:ListUsers",
        "iam:ListVirtualMFADevices",
        "iam:PassRole",
        "iam:PutRolePermissionsBoundary",
        "iam:PutUserPermissionsBoundary",
        "iam:TagUser",
        "iam:UpdateAccessKey",
        "iam:UpdateLoginProfile",
        "iam:UpdateServiceSpecificCredential",
        "iam:UpdateUser",
        "lambda:AddPermission",
        "lambda:GetFunction",
        "lambda:InvokeFunction",
        "sns:ListTagsForResource",
        "sns:ListTopics",
        "sns:Publish",
        "sns:SetSubscriptionAttributes",
        "sns:SetTopicAttributes",
        "lambda:UpdateFunctionConfiguration"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_secrets_user_accesskey_rotation" {
  name        = "lambda_secrets_user_accesskey_rotation"
  description = "IAM Policy for for using Lambda to rotate iam accesskeys"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
      "Action": [
        "secretsmanager:CreateSecret",
        "secretsmanager:DescribeSecret",
        "secretsmanager:GetResourcePolicy",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:ListSecrets",
        "secretsmanager:PutResourcePolicy",
        "secretsmanager:PutSecretValue",
        "secretsmanager:RotateSecret",
        "secretsmanager:TagResource",
        "secretsmanager:UpdateSecret",
        "secretsmanager:UpdateSecretVersionStage",
        "secretsmanager:ValidateResourcePolicy",
        "secretsmanager:RestoreSecret"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

#input a terraform data{get all iam users}, filter out any var.username_exceptions, then foreach user in usernames terraform attach policy below.
#Every user that is getting accesskeys rotated needs the below policy, or parts added to existing permissions.  
#This is so they can view the secret that was created for their username
/*
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "iam:DeactivateMFADevice",
                "iam:DeleteVirtualMFADevice",
                "iam:UpdateUser",
                "iam:EnableMFADevice",
                "iam:ResyncMFADevice",
                "iam:UpdateAccessKey",
                "iam:CreateVirtualMFADevice",
                "iam:GetUser",
                "iam:GetLoginProfile",
                "iam:ChangePassword",
                "iam:ListAccessKeys",
                "iam:ListUsers"
            ],
            "Resource": "arn:aws:iam::*:user/${aws:username}"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "iam:ListAccountAliases",
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "iam:ListMFADevices",
            "Resource": "arn:aws:iam::*:user/${aws:username}"
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": "iam:ListVirtualMFADevices",
            "Resource": "arn:aws:iam::*:user/${aws:username}"
        }
    ]
}
*/
