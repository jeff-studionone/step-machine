resource "aws_cloudtrail" "s3_read_images_event" {
  name                          = "${var.project_slug}-${var.env}-s3-read-images-event"
  s3_bucket_name                = aws_s3_bucket.events_storage.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = false
  tags                          = local.common_tags

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.read_images.arn}/"]
    }
  }
}

