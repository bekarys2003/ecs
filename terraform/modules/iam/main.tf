data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "${var.name}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
  tags               = var.tags
}

# Least-privilege: Lambda can send messages to the queue (ingest)
data "aws_iam_policy_document" "lambda_sqs_send" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes"
    ]
    resources = [var.queue_arn]
  }
}

resource "aws_iam_policy" "lambda_sqs_send" {
  name   = "${var.name}-lambda-sqs-send"
  policy = data.aws_iam_policy_document.lambda_sqs_send.json
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_send" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_sqs_send.arn
}

# Basic Lambda logging
resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ECS task role: read/consume messages (processor)
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.name}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
  tags               = var.tags
}

data "aws_iam_policy_document" "ecs_sqs_consume" {
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

resource "aws_iam_policy" "ecs_sqs_consume" {
  name   = "${var.name}-ecs-sqs-consume"
  policy = data.aws_iam_policy_document.ecs_sqs_consume.json
}

resource "aws_iam_role_policy_attachment" "ecs_sqs_consume" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_sqs_consume.arn
}
