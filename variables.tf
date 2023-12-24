variable "region" {
  type = string
}

variable "profile" {
  type = string
}

variable "rsa_public" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type = string
}

variable "email" {
  type = string
}