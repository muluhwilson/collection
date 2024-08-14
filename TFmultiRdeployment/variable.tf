variable "profile" {
  type    = string
  default = "default"
}

variable "region-master" {
  type    = string
  default = "us-west-2"
}

variable "region-worker" {
  type    = string
  default = "us-west-1"
}



variable "external_ip" {
  type    = string
  default = "0.0.0.0/0"
}