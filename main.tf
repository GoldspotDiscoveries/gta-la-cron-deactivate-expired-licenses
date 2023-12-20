provider "aws" {
  profile                  = "default"
  region                   = "us-west-1"
  shared_credentials_files = ["./credentials"]
}

terraform {
  backend "s3" {
    bucket = "gs-platform-terraform"
    region = "us-west-1"
    # Only one file containing all worksapces
    key = "frontend/gta-la-cron-deactivate-expired-licenses.tfstate"
  }
}

# LAMBDAS COULD BE IN A DIFFERENT FILE
data "archive_file" "gta-la-cron-deactivate-expired-licenses_zip" {
  type = "zip"
  # The code will be different depending on the branch so the name stays the same
  source_dir  = "gta-la-cron-deactivate-expired-licenses"
  output_path = "zip/gta-la-cron-deactivate-expired-licenses.zip"
}

resource "aws_lambda_function" "gta-la-cron-deactivate-expired-licenses" {
  function_name = "gta-la-cron-deactivate-expired-licenses-${local.environment}"
  role          = "arn:aws:iam::053085812890:role/gs-platform-lambda-dyamodb-us-west-1"
  handler       = "gta-la-cron-deactivate-expired-licenses.lambda_handler"
  memory_size   = 128
  runtime       = "python3.11"
  filename      = "zip/gta-la-cron-deactivate-expired-licenses.zip"
  timeout       = local.timeout
  layers        = ["arn:aws:lambda:us-west-1:053085812890:layer:gsp-sdk-gsapi:6"]

  environment {
    variables = {
      ENVIRONMENT = "${local.environment}"
    }
  }

  tags = {
    environment = "gsp-${local.environment}"
  }

  source_code_hash = data.archive_file.gta-la-cron-deactivate-expired-licenses_zip.output_base64sha256
}

resource "aws_cloudwatch_event_rule" "gta-la-cron-deactivate-expired-licenses_event_rule" {
  name = "gta-la-cron-deactivate-expired-licenses-${local.environment}"
  # 8am UTC = 4am EST
  # m h d m wd y (cron but no seconds)
  schedule_expression = "cron(0 8 ? * * *)"
}

resource "aws_cloudwatch_event_target" "gta-la-cron-deactivate-expired-licenses_lambda_target" {
  rule      = aws_cloudwatch_event_rule.gta-la-cron-deactivate-expired-licenses_event_rule.name
  target_id = aws_lambda_function.gta-la-cron-deactivate-expired-licenses.function_name
  arn       = aws_lambda_function.gta-la-cron-deactivate-expired-licenses.arn
  retry_policy {
    maximum_event_age_in_seconds = 60
    maximum_retry_attempts = 0
  }

}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.gta-la-cron-deactivate-expired-licenses.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.gta-la-cron-deactivate-expired-licenses_event_rule.arn
}
