variable "lambda_name" {
  description = "permanent name of the lambda function"
  type        = string
  default     = "iam_user_rotate_accesskeys"
}

variable "region" {
  description = "region this is deploying to"
  type        = string
  default     = "us-east-1"
}

variable "lambda_key_retire_name" {
  description = "permanent name of the accesskey deactivation lambda function"
  type        = string
  default     = "remove_inactive_accesskeys"
}

variable "iam_user_rotate_sns_topic" {
  description = "permanent name of the rotation sns topic email lambda function"
  type        = string
  default     = "iam_user_rotate_sns_topic"
}

variable "event_frequency" {
  description = "how often the lambda accesskey check gets ran to check for outdated keys."
  type        = string
  default     = "rate(1 day)"
}

variable "days_to_rotate" {
  description = "age in days that an IAM user accesskeys should be rotated on/after"
  type        = string
  default     = 90
}

variable "days_to_remove_inactive" {
  description = "age in days that an IAM user accesskeys should be rotated on/after"
  type        = string
  default     = 15
}

variable "username_exceptions" {
  description = "list of IAM users that should be exempted from the key rotations"
  type        = list(string)
  default     = []
}

variable "sns_alert_emails" {
  description = "emails to send usernames that keys changed for.(no keys or secrets are sent, all in SEC manager)"
  type        = list(string)
  default     = []
}
