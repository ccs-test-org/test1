resource "aws_s3_bucket" "data" {
  # bucket is public
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  bucket        = "${local.resource_prefix.value}-data"
  force_destroy = true
  tags = {
    Name        = "data"
    env         = "prod"
    cost-center = "11010"
    yor_trace   = "052deb6c-6b07-4f76-b06f-88650923e293"
  }
}

resource "aws_s3_bucket_object" "data_object" {
  bucket = aws_s3_bucket.data.id
  key    = "customer-master.xlsx"
  source = "resources/customer-master.xlsx"
  tags = {
    env         = "prod"
    cost-center = "11010"
    yor_trace   = "6c4d4572-4248-4ddc-ac4b-8809691f5c5d"
  }
}

resource "aws_s3_bucket" "financials" {
  # bucket is not encrypted
  # bucket does not have access logs
  # bucket does not have versioning
  bucket        = "${local.resource_prefix.value}-financials"
  acl           = "private"
  force_destroy = true
  tags = {
    env         = "prod"
    cost-center = "11010"
    yor_trace   = "2c688fa6-e972-40a8-a01e-5a4bae6eb034"
  }
}

resource "aws_s3_bucket" "financials_log_bucket" {
  bucket = "financials-log-bucket"
  tags = {
    yor_trace = "d37430e0-7c54-494c-bf29-05e0e9f4c080"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "financials_log_bucket" {
  bucket = aws_s3_bucket.financials_log_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


resource "aws_s3_bucket_logging" "financials" {
  bucket = aws_s3_bucket.financials.id

  target_bucket = aws_s3_bucket.financials_log_bucket.id
  target_prefix = "log/"
}


resource "aws_s3_bucket" "operations" {
  # bucket is not encrypted
  # bucket does not have access logs
  bucket = "${local.resource_prefix.value}-operations"
  acl    = "private"
  versioning {
    enabled = true
  }
  force_destroy = true
  tags = {
    env         = "prod"
    cost-center = "11010"
    yor_trace   = "89966ca6-7e51-4be9-b481-40431107ce8e"
  }
}

resource "aws_s3_bucket" "data_science" {
  # bucket is not encrypted
  bucket = "${local.resource_prefix.value}-data-science"
  acl    = "private"
  versioning {
    enabled = true
  }
  logging {
    target_bucket = aws_s3_bucket.logs.id
    target_prefix = "log/"
  }
  force_destroy = true
  tags = {
    env         = "prod"
    cost-center = "11010"
    yor_trace   = "7167884c-a112-4d58-a6e5-fc05c8d85f93"
  }
}

resource "aws_s3_bucket" "logs" {
  #checkov:skip=CKV_AWS_18:AWS Access logging not enabled on S3 buckets
  bucket = "${local.resource_prefix.value}-logs"
  acl    = "log-delivery-write"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.logs_key.arn
      }
    }
  }
  force_destroy = true
  tags = {
    env         = "prod"
    cost-center = "11010"
    funct       = "logging"
    yor_trace   = "86267982-d13a-48ac-a525-406af97cc8d3"
  }
}
