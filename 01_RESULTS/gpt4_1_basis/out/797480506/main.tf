# Minimal AWS infrastructure for Rekognition-based Step Function

resource "aws_iam_role" "step_function_role" {
  name = "${var.app_name}-step-function-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "states.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "rekognition_policy" {
  name        = "${var.app_name}-rekognition-policy"
  description = "Allow Step Functions to call Rekognition APIs"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rekognition:DetectFaces",
          "rekognition:DetectLabels",
          "rekognition:DetectModerationLabels",
          "rekognition:DetectProtectiveEquipment",
          "rekognition:DetectText"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "step_function_attach" {
  role       = aws_iam_role.step_function_role.name
  policy_arn = aws_iam_policy.rekognition_policy.arn
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket        = "${var.app_name}-artifacts-${random_id.suffix.hex}"
  force_destroy = true
  tags = {
    Name = "${var.app_name}-artifacts"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_sfn_state_machine" "rekognition_state_machine" {
  name       = "${var.app_name}-state-machine"
  role_arn   = aws_iam_role.step_function_role.arn
  definition = file("${path.module}/../state_machine/Rekognition.json")
}
