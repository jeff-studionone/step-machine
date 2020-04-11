resource "aws_s3_bucket" "read_images" {
  bucket = "${var.project_slug}-${var.env}-read-images"
  tags   = local.common_tags
  acl    = "public-read"
}

resource "aws_s3_bucket" "events_storage" {
  bucket        = "${var.project_slug}-${var.env}-events-storage"
  tags          = local.common_tags
  acl           = "private"
  force_destroy = true
  policy        = data.aws_iam_policy_document.s3_events_storage_permission_policy.json
}
