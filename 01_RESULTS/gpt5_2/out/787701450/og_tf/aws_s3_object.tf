resource "aws_s3_object" "comprehend" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "comprehend/"
}

resource "aws_s3_object" "datalake" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "datalake/"
}

resource "aws_s3_object" "datalake_comprehend" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake.key}comprehend/"
}

resource "aws_s3_object" "datalake_comprehend_entity" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}entity/"
}

resource "aws_s3_object" "datalake_comprehend_key_phrase" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}key_phrase/"
}

resource "aws_s3_object" "datalake_comprehend_pii_entity" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}pii_entity/"
}

resource "aws_s3_object" "datalake_comprehend_sentiment" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}sentiment/"
}

resource "aws_s3_object" "datalake_comprehend_sentiment_score" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}sentiment_score/"
}

resource "aws_s3_object" "datalake_comprehend_syntax_token" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}syntax_token/"
}

resource "aws_s3_object" "datalake_comprehend_syntax_token_part_of_speech" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}syntax_token_part_of_speech/"
}

resource "aws_s3_object" "datalake_comprehend_targeted_sentiment" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}targeted_sentiment/"
}

resource "aws_s3_object" "datalake_comprehend_targeted_sentiment_descriptive_mention" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}targeted_sentiment_descriptive_mention/"
}

resource "aws_s3_object" "datalake_comprehend_targeted_sentiment_mention" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}targeted_sentiment_mention/"
}

resource "aws_s3_object" "datalake_comprehend_targeted_sentiment_mention_sentiment" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}targeted_sentiment_mention_sentiment/"
}

resource "aws_s3_object" "datalake_comprehend_targeted_sentiment_mention_sentiment_score" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}targeted_sentiment_mention_sentiment_score/"
}

resource "aws_s3_object" "datalake_comprehend_toxic_content" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}toxic_content/"
}

resource "aws_s3_object" "datalake_comprehend_toxic_content_label" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "${aws_s3_object.datalake_comprehend.key}toxic_content_label/"
}


resource "aws_s3_object" "glue" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "glue/"
}

resource "aws_s3_object" "text" {
  bucket           = aws_s3_bucket.main.id
  content_language = "en-US"
  content_type     = "application/x-directory"
  force_destroy    = true
  key              = "text/"
}
