# SES Module

This module manages:

- SES domain identities
- SES email identities
- SES SMTP IAM user and credentials

## Inputs

- `domains`: list of domain names to add as SES identities
- `verified_email_addresses`: list of email addresses to verify in SES
- `create_smtp_user`: create SMTP IAM user when `true`
- `smtp_user_name`: optional custom SMTP IAM username

## Notes

- The module outputs SES domain verification tokens and DKIM tokens. Add them in your DNS provider (Microsoft DNS) to complete verification.
- Add future domains/emails by extending the lists in environment tfvars.
