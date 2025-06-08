variable "auth_url" {}
variable "tenant_name" {}
variable "user_name" {}
variable "password" {}
variable "region" {}
variable "image_name" {}
variable "master_flavor" {}
variable "worker_flavor" {}
variable "key_pair" {}
variable "network_name" {}
variable "worker_count" {
  default = 2
}