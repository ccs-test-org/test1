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
    yor_name    = "data"
    yor_trace   = "f06ec23c-e8c4-4fd3-befd-4c4337010b72"
  }
}

resource "aws_s3_bucket_object" "data_object" {
  bucket = aws_s3_bucket.data.id
  key    = "customer-master.xlsx"
  source = "resources/customer-master.xlsx"
  tags = {
    env         = "prod"
    cost-center = "11010"
    yor_name    = "data_object"
    yor_trace   = "39159d91-bdb6-4253-9f4a-8af5cb46ded2"
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
    yor_name    = "financials"
    yor_trace   = "d6432abe-ef1c-4807-a834-e0eb68dfe210"
  }
}

resource "aws_s3_bucket" "financials_log_bucket" {
  bucket = "financials-log-bucket"
  tags = {
    yor_name  = "financials_log_bucket"
    yor_trace = "1b9f4f01-74fb-4e51-8786-be54f425a20a"
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
    yor_name    = "operations"
    yor_trace   = "766247bf-45b7-4a55-b137-33dfae7eb161"
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
    yor_name    = "data_science"
    yor_trace   = "055e1caa-c399-4a92-9ab4-25635cc4308a"
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
    yor_name    = "logs"
    yor_trace   = "3293d4b0-4827-4e49-b1b8-80e91865a553"
  }
}
