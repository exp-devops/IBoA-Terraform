locals {
	normalized_domains = toset([for domain in var.domains : lower(trimspace(domain)) if trimspace(domain) != ""])
	normalized_emails  = toset([for email in var.verified_email_addresses : lower(trimspace(email)) if trimspace(email) != ""])

	smtp_username = coalesce(var.smtp_user_name, "${var.project_name}-${var.project_env}-ses-smtp")
}

resource "aws_ses_domain_identity" "this" {
	for_each = local.normalized_domains

	domain = each.value
}

resource "aws_ses_domain_dkim" "this" {
	for_each = aws_ses_domain_identity.this

	domain = each.value.domain
}

resource "aws_ses_email_identity" "this" {
	for_each = local.normalized_emails

	email = each.value
}

resource "aws_iam_user" "smtp" {
	count = var.create_smtp_user ? 1 : 0

	name = local.smtp_username
	tags = var.tags
}

resource "aws_iam_user_policy" "smtp_send" {
	count = var.create_smtp_user ? 1 : 0

	name = "${local.smtp_username}-ses-send"
	user = aws_iam_user.smtp[0].name

	policy = jsonencode({
		Version = "2012-10-17"
		Statement = [
			{
				Effect = "Allow"
				Action = [
					"ses:SendEmail",
					"ses:SendRawEmail"
				]
				Resource = "*"
			}
		]
	})
}

resource "aws_iam_access_key" "smtp" {
	count = var.create_smtp_user ? 1 : 0

	user = aws_iam_user.smtp[0].name
}

resource "aws_iam_user_policy_attachment" "smtp_secret_readonly" {
	count = var.create_smtp_user && var.secret_readonly_policy_arn != null ? 1 : 0

	user       = aws_iam_user.smtp[0].name
	policy_arn = var.secret_readonly_policy_arn
}

resource "aws_iam_user_policy_attachment" "smtp_kms_readonly" {
	count = var.create_smtp_user && var.kms_readonly_policy_arn != null ? 1 : 0

	user       = aws_iam_user.smtp[0].name
	policy_arn = var.kms_readonly_policy_arn
}
