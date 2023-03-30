variable "event_frequency" {
  description = "how often the lambda accesskey check gets ran to check for outdated keys."
  type        = string
  default     = "rate(1 day)"
}

variable "days_to_rotate" {
  description = "age in days that an IAM user accesskeys should be rotated on/after"
  type        = string
}

variable "days_to_remove_inactive" {
  description = "age in days that an IAM user accesskeys should be rotated on/after"
  type        = string
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
