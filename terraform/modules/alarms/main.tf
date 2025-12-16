resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.name}-dlq-visible-gt-0"
  alarm_description   = "DLQ has messages visible (poison messages / processing failures)."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = var.dlq_name
  }
}
