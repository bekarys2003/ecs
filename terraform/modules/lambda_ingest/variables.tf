variable "name" { type = string }
variable "role_arn" { type = string }
variable "queue_url" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
