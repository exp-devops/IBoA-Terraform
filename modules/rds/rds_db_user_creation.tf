# ### IAM Role for Lambda ###
# resource "aws_iam_role" "lambda_exec" {
#   name = "lambda-rds-access-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       },
#       Effect = "Allow",
#     }]
#   })
# }

# ### Attach VPC Access Execution Policy ###
# resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
#   role       = aws_iam_role.lambda_exec.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
# }

# ### Build Lambda ZIP (locally, without Docker) ###
# resource "null_resource" "package_lambda_zip" {
#   count = var.run_lambda_init ? 1 : 0

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "[*] Building Lambda without Docker..."

#       rm -rf modules/rds/lambda_build init_db_lambda.zip
#       mkdir -p modules/rds/lambda_build

#       pip install psycopg2-binary -t modules/rds/lambda_build/
#       cp modules/rds/init_db_lambda.py modules/rds/lambda_build/

#       cd modules/rds/lambda_build
#       zip -r ../init_db_lambda.zip .
#       cd ../../../

#       echo "[✓] Lambda zip created."
# EOT
#   }

#   triggers = {
#     always_run = timestamp()
#   }
# }

# ### Lambda Function ###
# resource "aws_lambda_function" "init_rds_lambda" {
#   filename         = "${path.module}/init_db_lambda.zip"
#   function_name    = "init-rds-user-db"
#   role             = aws_iam_role.lambda_exec.arn
#   handler          = "init_db_lambda.lambda_handler"
#   runtime          = "python3.11"
#   timeout          = 30

#   vpc_config {
#     subnet_ids         = [var.private_subnet_01, var.private_subnet_02]
#     security_group_ids = [var.bastion_sg_id]
#   }

#   environment {
#     variables = {
#       DB_HOST     = aws_db_instance.tf_db_instance.address
#       DB_NAME     = var.rdsProperty["DATABASE_NAME"]
#       DB_USER     = var.rdsProperty["USERNAME"]
#       DB_PASSWORD = random_password.master_password_rds.result
#       DB_PORT     = var.rdsProperty["PORT"]
#     }
#   }

#   depends_on = [null_resource.package_lambda_zip]
# }

# ### Invoke Lambda and Clean Up ###
# resource "null_resource" "init_rds_user" {
#   count = var.run_lambda_init ? 1 : 0
#   depends_on = [aws_lambda_function.init_rds_lambda]

#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#       echo "[*] Invoking Lambda function..."
#       aws lambda invoke --function-name init-rds-user-db --payload '{}' --region ${var.aws_region} output.json

#       echo "[*] Cleaning up artifacts..."
#       rm -rf modules/rds/lambda_build
#       rm -f modules/rds/init_db_lambda.zip

#       echo "[✓] Done."
# EOT
#   }
# }
