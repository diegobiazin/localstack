provider "aws" {
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    s3_force_path_style         = true
    access_key                  = "mock_access_key"
    secret_key                  = "mock_secret_key"
    region                      = "us-east-1"

    endpoints {
        apigateway     = "http://localhost:4566"
        cloudformation = "http://localhost:4566"
        cloudwatch     = "http://localhost:4566"
        dynamodb       = "http://localhost:4566"
        es             = "http://localhost:4566"
        firehose       = "http://localhost:4566"
        iam            = "http://localhost:4566"
        kinesis        = "http://localhost:4566"
        lambda         = "http://localhost:4566"
        route53        = "http://localhost:4566"
        redshift       = "http://localhost:4566"
        s3             = "http://localhost:4566"
        secretsmanager = "http://localhost:4566"
        ses            = "http://localhost:4566"
        sns            = "http://localhost:4566"
        sqs            = "http://localhost:4566"
        ssm            = "http://localhost:4566"
        stepfunctions  = "http://localhost:4566"
        sts            = "http://localhost:4566"
    }
}

resource "aws_iam_role" "iam_for_lambda" {
    name               = "iam_for_lambda"
    assume_role_policy = data.aws_iam_policy_document.assume.json 
}

data "aws_iam_policy_document" "assume" {
    statement {
      actions = ["sts:AssumeRole"]
      principals {
        type        = "Service"
        identifiers = ["lambda.amazonaws.com"]
      }
    }
}

resource "aws_lambda_permission" "allow_bucket" {
    statement_id  = "AllowExecutionFromS3Bucket"
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.func.arn
    principal     = "s3.amazonaws.com"
    source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_lambda_function" "func" {
    filename         = "function.zip"
    function_name    = "example_lambda_name"
    role             = aws_iam_role.iam_for_lambda.arn
    handler          = "index.handler"
    source_code_hash = data.archive_file.function.output_base64sha256
    runtime          = "nodejs12.x"
    timeout          = 30
}

resource "aws_s3_bucket" "bucket" {
    bucket = "my-bucket-name"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
    bucket = aws_s3_bucket.bucket.id

    lambda_function {
        lambda_function_arn = aws_lambda_function.func.arn
        events              = ["s3:ObjectCreated:*"]
        filter_prefix       = "AWSLogs/"
    }

    depends_on = [aws_lambda_permission.allow_bucket]
}

data "archive_file" "function" {
  type = "zip"
  source_file = "../index.js"
  output_path = "function.zip"
}
