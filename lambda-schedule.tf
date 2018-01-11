resource "aws_lambda_permission" "lambda-permission" {
  count = "${var.enabled == "true" ? 1 : 0}"
  statement_id = "AllowExecutionFromCloudWatch"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda-function.function_name}"
  principal = "events.amazonaws.com"
  source_arn = "${aws_cloudwatch_event_rule.lambda-schedule.arn}"
}

resource "aws_cloudwatch_event_rule" "lambda-schedule" {
  count = "${var.enabled == "true" ? 1 : 0}"
  name = "cloudflare-update-schedule"
  description = "Run ping check"

  schedule_expression = "${var.schedule_expression}"
}


resource "aws_cloudwatch_event_target" "lambda-schedule" {
  count = "${var.enabled == "true" ? 1 : 0}"
  rule = "${aws_cloudwatch_event_rule.lambda-schedule.name}"
  arn = "${aws_lambda_function.lambda-function.arn}"
}
