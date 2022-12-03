resource "aws_iam_policy" "send_tokens_policy" {
  name = "send_tokens_policy"
  description = "Policy to allow Lambda to get wallet and Infura secrets from Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "send_tokens_role" {
  name = "send_tokens_role"

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

resource "aws_iam_policy_attachment" "send_tokens" {
  name = "send_tokens_attachment"
  roles = [aws_iam_role.send_tokens_role.name]
  policy_arn = aws_iam_policy.send_tokens_policy.arn
}