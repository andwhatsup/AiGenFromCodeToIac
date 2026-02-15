data "aws_iam_policy" "logging" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "s3read" {
  name = "S3ReadAccess"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::gunjantest"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_role_policy_attachment" "lambda_to_log" {
  policy_arn = data.aws_iam_policy.logging.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role_policy_attachment" "lambda_to_s3" {
  policy_arn = aws_iam_policy.s3read.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_iam_role" "lambda_role" {
  name               = "ro-s3"
  path               = "/service-role/"
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

}
