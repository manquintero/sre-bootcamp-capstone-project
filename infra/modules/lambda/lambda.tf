locals {
  payload_name = "lambda_function_payload"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "lambda_handler_basic" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_handler_basic"
  output_path = "${path.module}/${local.payload_name}.zip"
}

resource "aws_lambda_function" "cidr_to_mask" {
  filename      = "${path.module}/${local.payload_name}.zip"
  function_name = "cidr_to_mask"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("${local.payload_name}.zip"))}"
  source_code_hash = filebase64sha256("${path.module}/${local.payload_name}.zip")

  runtime = "python3.8"

  # We're mocking this resource for the sake of testing the resource generation.
  depends_on = [
    data.archive_file.lambda_handler_basic,
  ]
}

resource "aws_lambda_function" "mask_to_cidr" {
  filename      = "${path.module}/${local.payload_name}.zip"
  function_name = "mask_to_cidr"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda_function.lambda_handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("${local.payload_name}.zip"))}"
  source_code_hash = filebase64sha256("${path.module}/${local.payload_name}.zip")

  runtime = "python3.8"

  # We're mocking this resource for the sake of testing the resource generation.
  depends_on = [
    data.archive_file.lambda_handler_basic,
  ]
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# 