# Loki
resource "aws_s3_bucket" "infra_sam_loki" {
  bucket = "infra-sam-loki-${terraform.workspace}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "infra_sam_loki_acl" {
  bucket = aws_s3_bucket.infra_sam_loki.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "infra_sam_loki" {
  bucket = aws_s3_bucket.infra_sam_loki.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Tempo
resource "aws_s3_bucket" "infra_sam_tempo" {
  bucket = "infra-sam-tempo-${terraform.workspace}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "infra_sam_tempo_acl" {
  bucket = aws_s3_bucket.infra_sam_tempo.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "infra_sam_tempo" {
  bucket = aws_s3_bucket.infra_sam_tempo.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Mimir
resource "aws_s3_bucket" "infra_sam_mimir" {
  bucket = "infra-sam-mimir-${terraform.workspace}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "infra_sam_mimir_acl" {
  bucket = aws_s3_bucket.infra_sam_mimir.id
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "infra_sam_mimir" {
  bucket = aws_s3_bucket.infra_sam_mimir.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}