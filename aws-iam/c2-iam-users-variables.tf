# INFO: Define IAM admin users

variable "user_admins" {
  type = set(string)
  default = [
    "robk"
  ]
}