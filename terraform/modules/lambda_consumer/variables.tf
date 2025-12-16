variable "name" { type = string }

variable "queue_arn" {
  type        = string
  description = "SQS queue ARN to consume from"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "timeout" {
  type    = number
  default = 30
}
