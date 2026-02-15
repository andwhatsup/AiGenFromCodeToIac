resource "aws_sqs_queue_policy" "s3_object_created_comprehend" {
  policy    = data.aws_iam_policy_document.sqs_queue_s3_bucket_notification_created_comprehend.json
  queue_url = aws_sqs_queue.s3_object_created_comprehend.id
}

resource "aws_sqs_queue_policy" "s3_object_created_text" {
  policy    = data.aws_iam_policy_document.sqs_queue_s3_bucket_notification_created_text.json
  queue_url = aws_sqs_queue.s3_object_created_text.id
}
