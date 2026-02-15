resource "aws_sfn_state_machine" "s3_object_created_comprehend" {
  definition = templatefile("./state_machine/S3ObjectCreatedComprehend.json", {
    aws_s3_object_key_entity                                     = aws_s3_object.datalake_comprehend_entity.key
    aws_s3_object_key_key_phrase                                 = aws_s3_object.datalake_comprehend_key_phrase.key
    aws_s3_object_key_pii_entity                                 = aws_s3_object.datalake_comprehend_pii_entity.key
    aws_s3_object_key_sentiment                                  = aws_s3_object.datalake_comprehend_sentiment.key
    aws_s3_object_key_sentiment_score                            = aws_s3_object.datalake_comprehend_sentiment_score.key
    aws_s3_object_key_syntax_token                               = aws_s3_object.datalake_comprehend_syntax_token.key
    aws_s3_object_key_syntax_token_part_of_speech                = aws_s3_object.datalake_comprehend_syntax_token_part_of_speech.key
    aws_s3_object_key_targeted_sentiment                         = aws_s3_object.datalake_comprehend_targeted_sentiment.key
    aws_s3_object_key_targeted_sentiment_descriptive_mention     = aws_s3_object.datalake_comprehend_targeted_sentiment_descriptive_mention.key
    aws_s3_object_key_targeted_sentiment_mention                 = aws_s3_object.datalake_comprehend_targeted_sentiment_mention.key
    aws_s3_object_key_targeted_sentiment_mention_sentiment       = aws_s3_object.datalake_comprehend_targeted_sentiment_mention_sentiment.key
    aws_s3_object_key_targeted_sentiment_mention_sentiment_score = aws_s3_object.datalake_comprehend_targeted_sentiment_mention_sentiment_score.key
    aws_s3_object_key_toxic_content                              = aws_s3_object.datalake_comprehend_toxic_content.key
    aws_s3_object_key_toxic_content_label                        = aws_s3_object.datalake_comprehend_toxic_content_label.key
  })
  name     = "${local.organization}-s3-object-created-comprehend"
  role_arn = aws_iam_role.sfn_state_machine_s3_object_created_comprehend.arn
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}

resource "aws_sfn_state_machine" "s3_object_created_text" {
  definition = templatefile("./state_machine/S3ObjectCreatedText.json", {
    aws_s3_object_key = aws_s3_object.comprehend.key
  })
  name     = "${local.organization}-s3-object-created-text"
  role_arn = aws_iam_role.sfn_state_machine_s3_object_created_text.arn
  tags = {
    account_arn  = data.aws_caller_identity.main.arn
    account_id   = data.aws_caller_identity.main.account_id
    organization = local.organization
    region       = data.aws_region.main.name
    workspace    = terraform.workspace
  }
}
