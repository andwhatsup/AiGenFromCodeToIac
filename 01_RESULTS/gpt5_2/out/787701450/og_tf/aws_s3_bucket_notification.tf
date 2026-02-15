resource "aws_s3_bucket_notification" "main" {
  bucket = aws_s3_bucket.main.id

  depends_on = [
    aws_iam_role.pipes_pipe_s3_object_created_comprehend,
    aws_sqs_queue_policy.s3_object_created_text
  ]

  queue {
    events        = ["s3:ObjectCreated:Put"]
    filter_prefix = aws_s3_object.comprehend.key
    filter_suffix = ".json"
    id            = aws_sqs_queue.s3_object_created_comprehend.id
    queue_arn     = aws_sqs_queue.s3_object_created_comprehend.arn
  }

  queue {
    events        = ["s3:ObjectCreated:Put"]
    filter_prefix = aws_s3_object.text.key
    filter_suffix = ".txt"
    id            = aws_sqs_queue.s3_object_created_text.id
    queue_arn     = aws_sqs_queue.s3_object_created_text.arn
  }
}
