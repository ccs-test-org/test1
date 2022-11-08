
provider "aws" {
  profile = var.profile
  region  = var.region
}

provider "aws" {
  alias      = "plain_text_access_keys_provider"
  region     = "us-west-2"
  access_key = "AKIAVH55LJRQ7LNCG3VR"
  secret_key = "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"
}

terraform {
  backend "s3" {
    encrypt = true
  }
}
