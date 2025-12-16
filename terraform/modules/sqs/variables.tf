variable "name" {
  type = string
}

variable "visibility_timeout_seconds" {
  type    = number
  default = 60
}

variable "message_retention_seconds" {
  type    = number
  default = 345600 # 4 days
}

variable "max_receive_count" {
  type    = number
  default = 5
}

variable "tags" {
  type    = map(string)
  default = {}
}
