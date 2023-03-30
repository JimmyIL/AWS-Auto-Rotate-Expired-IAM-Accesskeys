module "rotate_iam_access_keys" {
  source                  = "./modules/rotate_iam_access_keys"
  days_to_rotate          = var.days_to_rotate
  days_to_remove_inactive = var.days_to_remove_inactive
  event_frequency         = var.event_frequency
  sns_alert_emails        = var.sns_alert_emails
}
