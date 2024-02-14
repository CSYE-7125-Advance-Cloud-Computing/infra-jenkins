variable "region" {
  type = string
}

variable "cidr_block" {
  type = string
}

variable "public_subnet" {
  type = number
}

variable "public_availability_zones" {
  type = number
}

variable "vpc_id" {
  type = number
}

variable "profile" {
  type = string
}

variable "public_key_path" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type = string
}

variable "email" {
  type = string
}