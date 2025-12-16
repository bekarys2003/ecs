variable "name" { type = string }

variable "queue_arn" {
  type        = string
  description = "Main SQS queue ARN"
}

variable "tags" {
  type    = map(string)
  default = {}
}
