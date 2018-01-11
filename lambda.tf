resource "aws_cloudwatch_log_group" "lambda-log-group" {
  name = "PingUptimeAlerter"
}

resource "aws_iam_role" "iam_for_lambda" {
  count = "${var.enabled == "true" ? 1 : 0}"
  name = "lambda-ping-uptime-alerter-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda-policy" {
  name = "lambda-ping-uptime-alerter-policy"
  description = "Basic lambda logging role"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": [
          "arn:aws:logs:*"
      ]
    },
    {
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": "${var.sns_topic_arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy" {
  role = "${aws_iam_role.iam_for_lambda.id}"
  policy_arn = "${aws_iam_policy.lambda-policy.arn}"
  depends_on = ["aws_iam_policy.lambda-policy"]
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "${path.module}/ping.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "lambda-function" {
  count = "${var.enabled == "true" ? 1 : 0}"

  function_name = "PingUptimeAlerter"
  filename = "${path.module}/lambda.zip"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  handler = "ping.lambda_handler"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  runtime = "python3.6"
  timeout = 60
  environment {
    variables {
      ADDRESS = "${var.address}",
      SNS_TOPIC_ARN = "${var.sns_topic_arn}"
    }
  }
}

