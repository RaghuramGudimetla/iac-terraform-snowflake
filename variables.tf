variable "account_id" {
  type    = string
  default = "886192468297"
}

variable "region" {
  type    = string
  default = "ap-southeast-2"
}

variable "account" {
  type    = string
  default = "qb11547.ap-southeast-2"
}

variable "role" {
  type    = string
  default = "terraform_role"
}

variable "user" {
  type    = string
  default = "terraform_user"
}

variable "environment" {
    type = string
    default = "test"
}