resource "aws_cloudwatch_event_rule" "sfn_event_rule" {
  name        = "${var.project_slug}-${var.env}-sfn-event-rule"
  tags        = local.common_tags
  description = "Trigger SFN when S3 has an object"
  role_arn    = aws_iam_role.event_sfn_invoke_assume_role.arn
  is_enabled  = true

  event_pattern = <<PATTERN
  {
    "source": [
      "aws.s3"
    ],
    "detail-type": [
      "AWS API Call via CloudTrail"
    ],
    "detail": {
      "eventSource": [
        "s3.amazonaws.com"
      ],
      "eventName": [
        "PutObject"
      ],
      "requestParameters": {
        "bucketName": [
          "${var.project_slug}-${var.env}-read-images"
        ]
      }
    }
  }
  PATTERN
}

resource "aws_cloudwatch_event_target" "sfn_event_target" {
  rule     = aws_cloudwatch_event_rule.sfn_event_rule.name
  arn      = aws_sfn_state_machine.sfn_step_machine.id
  role_arn = aws_iam_role.event_sfn_invoke_assume_role.arn
}


