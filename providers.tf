variable "AWS_PROFILE" {}
provider "aws" {
  region     = "${var.aws_region}"
}
