data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  bucket_name = coalesce(var.bucket_name, format("%s-%s-%s", var.app_name, data.aws_caller_identity.current.account_id, data.aws_region.current.id))

  # Step Functions definitions are sourced from the repository JSON and parameterized
  # by replacing placeholder strings like ${aws_s3_object_key}.
  sfn_definition_text = replace(
    file("${path.module}/../state_machine/S3ObjectCreatedText.json"),
    "$${aws_s3_object_key}",
    var.comprehend_prefix
  )

  sfn_definition_comprehend = replace(
    replace(
      replace(
        replace(
          replace(
            replace(
              replace(
                replace(
                  replace(
                    replace(
                      replace(
                        replace(
                          replace(
                            replace(
                              file("${path.module}/../state_machine/S3ObjectCreatedComprehend.json"),
                              "$${aws_s3_object_key_entity}", "${var.datalake_prefix}model=entity/"
                            ),
                            "$${aws_s3_object_key_key_phrase}", "${var.datalake_prefix}model=key_phrase/"
                          ),
                          "$${aws_s3_object_key_pii_entity}", "${var.datalake_prefix}model=pii_entity/"
                        ),
                        "$${aws_s3_object_key_sentiment}", "${var.datalake_prefix}model=sentiment/"
                      ),
                      "$${aws_s3_object_key_sentiment_score}", "${var.datalake_prefix}model=sentiment_score/"
                    ),
                    "$${aws_s3_object_key_syntax_token}", "${var.datalake_prefix}model=syntax_token/"
                  ),
                  "$${aws_s3_object_key_syntax_token_part_of_speech}", "${var.datalake_prefix}model=syntax_token_part_of_speech/"
                ),
                "$${aws_s3_object_key_targeted_sentiment}", "${var.datalake_prefix}model=targeted_sentiment/"
              ),
              "$${aws_s3_object_key_targeted_sentiment_descriptive_mention}", "${var.datalake_prefix}model=targeted_sentiment_descriptive_mention/"
            ),
            "$${aws_s3_object_key_targeted_sentiment_mention}", "${var.datalake_prefix}model=targeted_sentiment_mention/"
          ),
          "$${aws_s3_object_key_targeted_sentiment_mention_sentiment}", "${var.datalake_prefix}model=targeted_sentiment_mention_sentiment/"
        ),
        "$${aws_s3_object_key_targeted_sentiment_mention_sentiment_score}", "${var.datalake_prefix}model=targeted_sentiment_mention_sentiment_score/"
      ),
      "$${aws_s3_object_key_toxic_content}", "${var.datalake_prefix}model=toxic_content/"
    ),
    "$${aws_s3_object_key_toxic_content_label}", "${var.datalake_prefix}model=toxic_content_label/"
  )
}

resource "aws_s3_bucket" "pipeline" {
  bucket        = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "pipeline" {
  bucket = aws_s3_bucket.pipeline.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline" {
  bucket = aws_s3_bucket.pipeline.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline" {
  bucket = aws_s3_bucket.pipeline.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_sqs_queue" "text_events" {
  name                       = "${var.app_name}-s3-text"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 60
}

resource "aws_sqs_queue" "comprehend_events" {
  name                       = "${var.app_name}-s3-comprehend"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 60
}

# Allow S3 to send messages to the queues
resource "aws_sqs_queue_policy" "text_events" {
  queue_url = aws_sqs_queue.text_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3SendMessage"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.text_events.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.pipeline.arn
          }
        }
      }
    ]
  })
}

resource "aws_sqs_queue_policy" "comprehend_events" {
  queue_url = aws_sqs_queue.comprehend_events.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowS3SendMessage"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.comprehend_events.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_s3_bucket.pipeline.arn
          }
        }
      }
    ]
  })
}

# S3 notifications to SQS for the two pipeline stages
resource "aws_s3_bucket_notification" "pipeline" {
  bucket = aws_s3_bucket.pipeline.id

  queue {
    queue_arn     = aws_sqs_queue.text_events.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.text_prefix
  }

  queue {
    queue_arn     = aws_sqs_queue.comprehend_events.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = var.comprehend_prefix
  }

  depends_on = [
    aws_sqs_queue_policy.text_events,
    aws_sqs_queue_policy.comprehend_events
  ]
}

# IAM role for Step Functions to call AWS SDK integrations (S3 + Comprehend)
resource "aws_iam_role" "sfn" {
  name = "${var.app_name}-sfn-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "sfn" {
  name = "${var.app_name}-sfn-policy"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ReadWrite"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.pipeline.arn}/*"
        ]
      },
      {
        Sid    = "ComprehendDetect"
        Effect = "Allow"
        Action = [
          "comprehend:DetectDominantLanguage",
          "comprehend:DetectEntities",
          "comprehend:DetectKeyPhrases",
          "comprehend:DetectPiiEntities",
          "comprehend:DetectSentiment",
          "comprehend:DetectSyntax",
          "comprehend:DetectTargetedSentiment",
          "comprehend:DetectToxicContent"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "s3_object_created_text" {
  name     = "${var.app_name}-S3ObjectCreatedText"
  role_arn = aws_iam_role.sfn.arn

  definition = local.sfn_definition_text
}

resource "aws_sfn_state_machine" "s3_object_created_comprehend" {
  name     = "${var.app_name}-S3ObjectCreatedComprehend"
  role_arn = aws_iam_role.sfn.arn

  definition = local.sfn_definition_comprehend
}
