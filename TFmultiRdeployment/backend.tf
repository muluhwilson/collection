
aws s3api create-bucket \
              --bucket terraformstate121 \
              --region us-west-2 \
              --create-bucket-configuration LocationConstraint=us-west-2

#
terraform {
  required_version = ">=0.12.2"
  backend "s3" {
    region  = "us-west-2"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "terraformstate121"
  }



