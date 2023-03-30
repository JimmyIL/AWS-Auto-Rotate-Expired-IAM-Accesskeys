
# Overview
Please understand THIS WILL ROTATE ALL IAM USERs for an account and create secrets in SecretsManager FOR EVERY USER that is not defined in the 'username_exception' variable
default rotates AccessKeys/secretkeys if created on or older than 90 days.

(depending on the amount of users, it could be costly for customers with a large amount of users since it is using SecretsManager)

IF there are automated service accounts in IAMusers you don't want to rotate, you can add them as a list to tfvars 'username_exceptions' and it will skip these users.

In the event a user only has 'INACTIVE' keys, no rotation or modification takes place.  Essentially that user is skipped.

In the event a user has NO keys, they will continue to have no keys.

In the rare event the user has 2 'ACTIVE' keys, this function will currently ALWAYS remove the oldest active key completely since IAM AccessKeys only allow 2 total and cannot be modified.

# How it Works
this deployment uses a Lambda function that rotates EVERY IAM user that you define every 90 days (default). 
Lambda function is triggered daily from an EventBridge timed event (previously CloudwatchEvents)

#This solution is pre-compiled and ready to deploy, the lambda is already packaged here in the repo (.zip)
# no dependencies and no S3 bucket needed (just your state bucket for reference in backend.config). Only need Terraform version 1.0.5 or higher, change vars to your liking and 'terraform apply'

- Variables for 'days till rotation', 'region', and 'days till inactive' are found in terraform.tfvars and can be changed.
- First Lambda function checks for keys that are 'inactive' for 15 days or more from the 'active' key creation date. 
- If inactive key is >= 15 days old it is removed/deleted
- First lambda Invokes Second lambda once completed for all usernames
- Lambda checks every user with at least 1 'active' key status all others are skipped and untouched.
- Selects only if an accesskey is 'active' and creation date is less than or equal to -90 days from today's date (90 days ago)
- deactivates previous existing key that >= 90 days  
- creates a new IAM user accesskey
- checks if secret name in SecretsManager already exists that matches '$user_credentials'
- if exists already;  updates secret with new keys created into secrets manager 
- writes a secrets permissions policy to the secret so that username can access his/her own new secret (only can retrieve own secret string)


IN Progress Lambda function for sns topic checking secrets update dates and sending an email with users that the rotation rotated keys for
(troubleshooting why its not working...)