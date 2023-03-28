provider "aws" {
  region = "us-east-1"
  access_key = "AKIA4CKSYB25PHP5ARHZ"
  secret_key="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"
}

##################
# Glue Catalog   #
resource "aws_glue_connection" "data_store" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:mysql://example.com/exampledatabase"
    PASSWORD            = "postgres"
    USERNAME            = "5Y67bg#r#"
  }

  name = "data_store"
}
##################


##################
# Glue Catalog   #
resource "aws_glue_catalog_database" "aws_glue_catalog_database" {
  name = "Banking"
}
##################


##################
# Glue Crawler   #
resource "aws_glue_crawler" "data_store_crawler" {
  database_name = aws_glue_catalog_database.aws_glue_catalog_database.name
  name          = "data_store_crawler"
  role          = aws_iam_role.bank_access.arn

  jdbc_target {
    connection_name = aws_glue_connection.data_store.name
    path            = "Banking"
  }
}
##################


##################
# Glue Job       #
resource "aws_glue_job" "banking_average_job" {
  name              = "banking_average_job"
  role_arn          = aws_iam_role.bank_access.arn
  glue_version      = "3.0"
  worker_type       = "G.1X"
  number_of_workers = 3

  command {
    script_location = "s3://aws-glue-assets-123456789-us-east-1/scripts/"
  }

  connections =  [aws_glue_connection.data_store.name]

  default_arguments = {
    "--additional-python-modules"        = "s3-concat"
    "--enable-continuous-cloudwatch-log" = "true"
  }
}
##################


##################
# S3 #
resource "aws_s3_bucket" "banking_output" {
  bucket = "banking_data/"

  tags = {
    Name        = "Banking output bucket to share"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "banking_output_encrypt" {
  bucket = aws_s3_bucket.banking_output.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
##################