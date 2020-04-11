resource "aws_sfn_state_machine" "sfn_step_machine" {
  name     = "${var.project_slug}-${var.env}-sfn"
  role_arn = aws_iam_role.sfn_assume_role.arn
  tags     = local.common_tags

  definition = file("${path.module}/jsonFiles/sfnDefinition.json")
}

