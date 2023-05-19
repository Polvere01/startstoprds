resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "rds_policy" {
  name        = "rds-policy"
  description = "Policy for accessing RDS"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action":  [
        "rds:ModifyDBCluster",
        "rds:StopDBCluster",
        "rds:StartDBCluster"
      ],
      "Resource": "arn:aws:rds:sa-east-1:604065395547:cluster:mysql-db-cluster"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "rds_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.rds_policy.arn
}

resource "aws_lambda_function" "my_lambda" {
  function_name    = "my-lambda-function"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.8"
  timeout          = 10
  memory_size      = 128
  publish          = true

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

resource "aws_lambda_permission" "allow_cloudwatch_event" {
  statement_id  = "AllowExecutionFromCloudWatchEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.my_event_rule.arn
}

resource "aws_cloudwatch_event_rule" "my_event_rule" {
  name        = "my-event-rule"
  description = "Rule for scheduling Lambda execution"
  schedule_expression = "cron(0 22,10 * * ? *)"  # Executar todos os dias às 20h e 7h UTC

  # Outras configurações da regra de evento...
}

resource "aws_cloudwatch_event_target" "my_event_target" {
  rule      = aws_cloudwatch_event_rule.my_event_rule.name
  arn       = aws_lambda_function.my_lambda.arn
}