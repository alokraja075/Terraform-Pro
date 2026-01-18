locals {
  build_dir = var.build_dir != null ? var.build_dir : "${path.cwd}/build"
}

# Package python source into a zip for Lambda
data "archive_file" "package" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${local.build_dir}/${var.function_name}.zip"
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  handler       = var.handler
  runtime       = var.runtime

  filename         = data.archive_file.package.output_path
  source_code_hash = data.archive_file.package.output_base64sha256

  timeout     = var.timeout
  memory_size = var.memory_size

  environment {
    variables = var.environment
  }

  tags = var.tags
}
