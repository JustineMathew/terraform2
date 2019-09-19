terraform {
  required_version = "0.12.3"
  backend "s3" {
    bucket = "automi-terraform"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
