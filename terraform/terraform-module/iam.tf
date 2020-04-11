# Permissions for SFN
data "aws_iam_policy_document" "sfn_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "states.amazonaws.com"
      ]
    }
  }
}

data "aws_iam_policy_document" "sfn_permission_policy" {
  statement {
    sid    = "sfnLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*"
    ]
  }

  statement {
    sid = "allowAllAccessToBucket"
    actions = [
      "s3:*"
    ]
    effect = "Allow"
    resources = [
      aws_s3_bucket.read_images.arn,
      aws_s3_bucket.events_storage.arn,
      "${aws_s3_bucket.read_images.arn}/*",
      "${aws_s3_bucket.events_storage.arn}/*",
    ]
  }
}

resource "aws_iam_role" "sfn_assume_role" {
  name               = "${var.project_slug}-${var.env}-sfn-assume-role"
  tags               = local.common_tags
  assume_role_policy = data.aws_iam_policy_document.sfn_role_policy.json
}

resource "aws_iam_policy" "sfn_policy" {
  name   = "${var.project_slug}-${var.env}-sfn-policy"
  policy = data.aws_iam_policy_document.sfn_permission_policy.json
}

resource "aws_iam_role_policy_attachment" "sfn_policy_attachment" {
  role       = aws_iam_role.sfn_assume_role.name
  policy_arn = aws_iam_policy.sfn_policy.arn
}

# Permission cloudWatch rule to invoke SFN
data "aws_iam_policy_document" "event_sfn_invoke_role_policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "states.amazonaws.com",
      ]
    }
  }
}

data "aws_iam_policy_document" "event_sfn_invoke_permission_policy" {
  statement {
    sid    = "allowToRegisterLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:CreateExportTask",
      "logs:DescribeExportTasks",
      "logs:DescribeLogGroups",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*"
    ]
  }

  statement {
    sid    = "allowRuleTargetStartSFN"
    effect = "Allow"
    actions = [
      "states:StartExecution"
    ]
    resources = [
      aws_sfn_state_machine.sfn_step_machine.id
    ]
  }
}

resource "aws_iam_role" "event_sfn_invoke_assume_role" {
  name               = "${var.project_slug}-${var.env}-event-sfn-invoke-assume-role"
  tags               = local.common_tags
  assume_role_policy = data.aws_iam_policy_document.event_sfn_invoke_role_policy.json
}

resource "aws_iam_policy" "event_sfn_invoke_policy" {
  name   = "${var.project_slug}-${var.env}-event-sfn-invoke-policy"
  policy = data.aws_iam_policy_document.event_sfn_invoke_permission_policy.json
}

resource "aws_iam_role_policy_attachment" "event_sfn_invoke_policy_attachment" {
  role       = aws_iam_role.event_sfn_invoke_assume_role.name
  policy_arn = aws_iam_policy.event_sfn_invoke_policy.arn
}

# S3 policy for bucket svents stored to allow put objects
data "aws_iam_policy_document" "s3_events_storage_permission_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    actions = [
      "s3:GetBucketAcl",
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    resources = [
      "arn:aws:s3:::${var.project_slug}-${var.env}-events-storage",
    ]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudtrail.amazonaws.com"
      ]
    }
    resources = [
      "arn:aws:s3:::${var.project_slug}-${var.env}-events-storage/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}
