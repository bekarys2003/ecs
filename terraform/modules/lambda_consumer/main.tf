data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/build/${var.name}.zip"
}

data "aws_iam_policy_document" "assume_lambda" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_lambda.json
  tags               = var.tags
}

# Least-privilege SQS consume permissions
data "aws_iam_policy_document" "sqs_consume" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]
    resources = [var.queue_arn]
  }
}

resource "aws_iam_policy" "sqs_consume" {
  name   = "${var.name}-sqs-consume"
  policy = data.aws_iam_policy_document.sqs_consume.json
}

resource "aws_iam_role_policy_attachment" "sqs_consume" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.sqs_consume.arn
}

# Basic logs
resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.name
  role          = aws_iam_role.this.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  timeout     = var.timeout
  memory_size = 128

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
  tags              = var.tags
}

# SQS -> Lambda trigger
resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = var.queue_arn
  function_name    = aws_lambda_function.this.arn

  batch_size                         = 10
  maximum_batching_window_in_seconds = 0
  enabled                            = true
}
