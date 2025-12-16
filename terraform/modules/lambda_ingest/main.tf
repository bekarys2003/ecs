data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/${var.name}.zip"
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = var.role_arn
  handler       = "lambda_function.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  timeout = 10
  memory_size = 128

  environment {
    variables = {
      QUEUE_URL = var.queue_url
    }
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
  tags              = var.tags
}
