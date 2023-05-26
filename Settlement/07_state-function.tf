
resource "aws_sfn_state_machine" "settlemnet_state_machine" {
  name     = "settlement-state-machine"
  role_arn = aws_iam_role.settlement_step_function_role.arn

  definition = templatefile("${path.module}/StepFunction/state.tftpl", {
    region     = "${data.aws_region.current.name}"
    account_id = "${data.aws_caller_identity.current.account_id}"
  })

}

