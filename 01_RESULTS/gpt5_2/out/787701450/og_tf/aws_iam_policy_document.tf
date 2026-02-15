data "aws_iam_policy_document" "assume_role_glue_crawler_datalake_comprehend" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = ["glue.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "assume_role_pipes_pipe_s3_object_created_comprehend" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = ["pipes.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "assume_role_pipes_pipe_s3_object_created_text" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = ["pipes.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "assume_role_sfn_state_machine_s3_object_created_comprehend" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = ["states.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "assume_role_sfn_state_machine_s3_object_created_text" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    effect = "Allow"
    principals {
      identifiers = ["states.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "glue_crawler_datalake_comprehend" {
  statement {
    actions = [
      "glue:GetDatabase",
      "glue:GetTables",
      "glue:CreateDatabase",
      "glue:CreateTable",
      "glue:DeleteTable",
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
      "glue:UpdateTable",
      "glue:CreatePartition",
      "glue:BatchCreatePartition",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
      "glue:UpdatePartition",
      "glue:DeletePartition",
      "glue:BatchDeletePartition"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:glue:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:catalog",
      "arn:aws:glue:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:database/${aws_glue_catalog_database.datalake_comprehend.name}",
      "arn:aws:glue:${data.aws_region.main.name}:${data.aws_caller_identity.main.account_id}:table/${aws_glue_catalog_database.datalake_comprehend.name}/*"
    ]
  }
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListAllMyBuckets",
      "s3:GetBucketAcl"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.main.arn}"
    ]
  }
  statement {
    actions = [
      "S3:GetObject",
      "S3:GetObjectVersion"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.main.arn}/${aws_s3_object.datalake_comprehend.key}*"
    ]
  }
  statement {
    actions = [
      "S3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.main.arn}/${aws_s3_object.glue.key}*"
    ]
  }
}

data "aws_iam_policy_document" "pipes_pipe_s3_object_created_comprehend" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    effect = "Allow"
    resources = [
      aws_sqs_queue.s3_object_created_comprehend.arn
    ]
  }
  statement {
    actions = [
      "states:StartExecution"
    ]
    effect = "Allow"
    resources = [
      aws_sfn_state_machine.s3_object_created_comprehend.arn
    ]
  }
}

data "aws_iam_policy_document" "pipes_pipe_s3_object_created_text" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
    effect = "Allow"
    resources = [
      aws_sqs_queue.s3_object_created_text.arn
    ]
  }
  statement {
    actions = [
      "states:StartExecution"
    ]
    effect = "Allow"
    resources = [
      aws_sfn_state_machine.s3_object_created_text.arn
    ]
  }
}

data "aws_iam_policy_document" "sfn_state_machine_s3_object_created_comprehend" {
  statement {
    actions = [
      "S3:GetObject",
      "S3:GetObjectVersion"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.main.arn}/${aws_s3_object.comprehend.key}*"
    ]
  }

  statement {
    actions = [
      "S3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.main.arn}/${aws_s3_object.datalake_comprehend.key}*"
    ]
  }
}

data "aws_iam_policy_document" "sfn_state_machine_s3_object_created_text" {
  statement {
    actions = [
      "S3:GetObject",
      "S3:GetObjectVersion"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.main.arn}/${aws_s3_object.text.key}*"
    ]
  }

  statement {
    actions = [
      "S3:PutObject"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.main.arn}/${aws_s3_object.comprehend.key}*"
    ]
  }

  statement {
    actions = [
      "comprehend:DetectDominantLanguage",
      "comprehend:DetectEntities",
      "comprehend:DetectKeyPhrases",
      "comprehend:DetectPiiEntities",
      "comprehend:DetectSentiment",
      "comprehend:DetectSyntax",
      "comprehend:DetectTargetedSentiment",
      "comprehend:DetectToxicContent"
    ]
    effect = "Allow"
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "sqs_queue_s3_bucket_notification_created_comprehend" {
  statement {
    actions = ["SQS:SendMessage"]

    condition {
      test     = "ArnLike"
      values   = [aws_s3_bucket.main.arn]
      variable = "aws:SourceArn"
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sqs_queue.s3_object_created_comprehend.arn
    ]
  }
}

data "aws_iam_policy_document" "sqs_queue_s3_bucket_notification_created_text" {
  statement {
    actions = ["SQS:SendMessage"]

    condition {
      test     = "ArnLike"
      values   = [aws_s3_bucket.main.arn]
      variable = "aws:SourceArn"
    }

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [
      aws_sqs_queue.s3_object_created_text.arn
    ]
  }
}
