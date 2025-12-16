provider "aws" {
  region = var.region_name
}

resource "aws_s3_bucket" "terraformbucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.terraformbucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraformbucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.terraformbucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_object" "all_files" {
  for_each = fileset("File", "**/*")

  bucket = aws_s3_bucket.terraformbucket.id
  key    = each.key
  source = "File/${each.key}"

    content_type = lookup(
    {
        html = "text/html"
        css  = "text/css"
        js   = "application/javascript"
        png  = "image/png"
        jpg  = "image/jpeg"
        jpeg = "image/jpeg"
        svg  = "image/svg+xml"
        json = "application/json"
    },
    lower(regex("^.*\\.([^.]+)$", each.key)[0]),
    "application/octet-stream"
    )
}

resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.terraformbucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.terraformbucket.arn}/*"]
      }
    ]
  })
}
