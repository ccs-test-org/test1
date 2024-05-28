resource "aws_iam_role" "iam_for_lambda" {
  name = "${local.resource_prefix.value}-analysis-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    env         = "dev"
    cost-center = "55010"
    yor_trace   = "97adb1e7-9b44-40c3-982c-2730f4189e7f"
  }
}

resource "aws_lambda_function" "analysis_lambda" {
  # lambda have plain text secrets in environment variables
  filename         = "resources/lambda_function_payload.zip"
  function_name    = "${local.resource_prefix.value}-analysis"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "exports.test"
  source_code_hash = filebase64sha256("resources/lambda_function_payload.zip")
  runtime          = "nodejs12.x"
  environment {
    variables = {
      access_key = "AKIAIOSFODNN7EXAMPLE"
      secret_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
    }
  }
  tags = {
    env         = "dev"
    cost-center = "55010"
    yor_trace   = "a9077ee4-205a-4035-9b19-f9773f21b68b"
  }
}

# data "archive_file" "lambda_zip" {
#     type          = "zip"
#     source_file   = "index.js"
#     output_path   = "lambda_function.zip"
# }

# resource "aws_lambda_function" "test_lambda" {
#   filename         = "lambda_function.zip"
#   function_name    = "test_lambda"
#   role             = "${aws_iam_role.iam_for_lambda.arn}"
#   handler          = "index.handler"
#   source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
#   runtime          = "nodejs6.10"
#   tags = {
#     env         = "test"
#     cost-center = "77010"
#   }
# }