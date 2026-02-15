###########################
# Bucket name
###########################
resource "aws_s3_bucket" "s3" {
  bucket = "s3-bucket-workshop-1001-pyday"
  tags = {
    Name        = "workshop-s3"
    Environment = "production"

  }

}


###########################
# Customer managed KMS key
###########################
resource "aws_kms_key" "kms_s3_key" {
  description             = "Key to protect S3 objects"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
}

resource "aws_kms_alias" "kms_s3_key_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.kms_s3_key.key_id
}


##########################
# Bucket private access
##########################
resource "aws_s3_bucket_acl" "s3_protected_bucket_acl" {
  bucket     = aws_s3_bucket.s3.id
  acl        = "private"
  depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.s3.id
  rule {
    object_ownership = "ObjectWriter"
  }
}
#############################
# Enable bucket versioning
#############################
resource "aws_s3_bucket_versioning" "s3_protected_bucket_versioning" {
  bucket = aws_s3_bucket.s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

##########################################
# Enable default Server Side Encryption
##########################################
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_protected_bucket_server_side_encryption" {
  bucket = aws_s3_bucket.s3.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

############################
# Creating Lifecycle Rule
############################
resource "aws_s3_bucket_lifecycle_configuration" "s3_protected_bucket_lifecycle_rule" {
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.s3_protected_bucket_versioning]

  bucket = aws_s3_bucket.s3.bucket

  rule {
    id     = "basic_config"
    status = "Enabled"

    filter {
      prefix = "config/"
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

  }
}


resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}

########################
# Disabling bucket
# public access
########################
resource "aws_s3_bucket_public_access_block" "s3_protected_bucket_access" {
  bucket = aws_s3_bucket.s3.id

  # Block public access
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = true
}


########################
# Creating objects
########################
resource "aws_s3_object" "website" {
  key    = "imagenes/index.html"
  bucket = aws_s3_bucket.s3.id
  source = "file/index.html"
}
