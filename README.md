
# Auto Rotate AWS IAM User active accesskeys <br>
This will rotate all IAM user's in an account and create secrets in SecretsManager. If you don't wish to rotate certain users define them in the 'username_exception' variable (see below)<br>
<br>
-this rotates AccessKeys/secretkeys if created on or after <x> days (defaults to 30 days unless specified).
<br>
-note:depending on the amount of users, it could be costly for customers with a large amount of users since this is storing the keys in AWS SecretsManager.<br>
(after the user grabs the secretkey, you can also delete the secret, but it will be re-created upon the next rotation.<br>
-IF there are automated service accounts as IAM user's you don't want to rotate, you can add them as a list to tfvars 'username_exceptions' and it will skip these users.
<br>
-In the event a user only has 'INACTIVE' keys, no rotation or modification takes place.  Essentially that user is just skipped.
<br>
-In the event a user has NO keys, they will continue to have no keys and skipped.
<br>
-In the rare event the user has 2 'ACTIVE' acesskeys, this function will currently ALWAYS rotate the oldest active key with a new accesskey completely (IAM AccessKeys only allow 2 total, this is the way..)<br>

# How it Works
this deployment uses a total of 2 Lambda functions that rotates IAM user accesskeys for every x days (30 day default or you can change in .tfvars file 'days_to_rotate'.). <br>

-A scheduled daily EventBridge Event triggers the 'remove_inactive_accesskeys' lambda function.  This lambda then checks the IAM accesskeys for inactive keys and removes them if according to the variable 'days_to_remove_inactive' (default is 15 days of being inactive). The user MUST also have an ACTIVE accesskey for this to work, otherwise it doesn't remove inactive keys for that user.<br>
-From the 'remove_inactive_acceskeys' lambda function the 'iam_user_rotate_accesskeys' lambda function is triggered.  This function sets the current expired accesskey to 'inactive', creates the new user accesskey and writes the new accesskey and secretkey into AWS Secrets Manager.  If the Secret name already exists, it is updated.  If the secret doesn't exist it's created.<br>

-Secrets Manager for that specific users secret has a policy attached that only allows Admin and that specific user to view the secret.<br>
<br>
<br>
## This solution is already compiled and ready to deploy, (those are the .zip files, those need to stay)<br>
#### no dependencies. Only need Terraform version 1.0.5 or higher, change variables that suits your rotation schedule needs and init + apply<br>
<br>
## TLDR? This is the Summary:<br>
- Variables for 'days till rotation', 'region', and 'days till inactive' are found in terraform.tfvars and can be changed.<br>
- First Lambda function checks for keys that are 'inactive' for x days (default 15 days).<br>
- If inactive key is >= 15 days old it is removed/deleted<br>
- First lambda Invokes Second lambda once completed for all usernames<br>
- Lambda checks every user with at least 1 'active' key status all others are skipped and untouched.<br>
- Selects only if an accesskey is 'active' and creation date is less than or equal to -90 days from today's date (90 days ago)<br>
- deactivates previous existing key that >= 90 days<br>
- creates a new IAM user accesskey<br>
- checks if secret name in SecretsManager already exists that matches '$user_credentials'<br>
- if exists already;  updates secret with new keys created into secrets manager<br>
- this writes a secrets permissions policy to the secret so that only the username that secret is for can access his/her own new secret (only can retrieve own secret string)<br>
<br>

IN Progress Lambda function for sns topic checking secrets update dates and sending an email with users that the rotation rotated keys for
(currently working on this...)
