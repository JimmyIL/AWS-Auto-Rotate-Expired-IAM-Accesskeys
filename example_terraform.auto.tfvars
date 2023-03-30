#if you already have a terraform .tfvars for doing plan and applies, add these to it and delete this file.

#Days till key is rotated at
days_to_rotate = 30

#Amount of Days Since current Active Accesskey creation date (to remove inactive key. default is 20)
days_to_remove_inactive = 15

#how often the eventbridge rule triggers outdated accesskey checks
event_frequency = "rate(1 day)"

#username_exceptions are for iam users doing automation things that we can't risk rotating keys for.
#each username exception needs to be wrapped in quotes and seperated by a comma with a space! just like this --> i.e ["freddy.automated_pipeline", "another.monitoringtool", "some_automated_outdated_app_user"]
#username_exceptions = ["scotty", "blueshirt.guy"]

#email you want alerts sent to, comment out if N/A
sns_alert_emails = ["someemail1@rackspace.com", "someemail2@rackspace.com"]
