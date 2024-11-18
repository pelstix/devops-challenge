# Configure the backend for storing the Terraform state in an S3 bucket
terraform {
  backend "s3" {
    bucket         = "lifinance-terraform-state-bucket"
    key            = "terraform/state.tfstate"  # Path within the bucket
    region         = "eu-west-2"

  }
}
