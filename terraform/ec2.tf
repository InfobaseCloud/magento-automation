locals {
  ec2 = toset(var.instance_ids)
}

# EC2 System failures
resource "aws_cloudwatch_metric_alarm" "system_failure" {
  for_each            = local.ec2
  alarm_name          = each.key
  alarm_description   = "The EC2 Status check has failed for ${each.key}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  period              = 60
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  statistic           = "Minimum"
  ok_actions          = [aws_sns_topic.this.arn]
  dimensions = {
    InstanceId : each.key
  }
  alarm_actions = [
    aws_sns_topic.this.arn,
    "arn:aws:automate:${data.aws_region.current.name}:ec2:reboot"
  ]
}

resource "aws_sns_topic" "this" {
  name              = "${var.name}-ec2-reboot"
  kms_master_key_id = aws_kms_key.this.key_id
  delivery_policy   = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
}

resource "aws_sns_topic_policy" "this" {
  arn    = aws_sns_topic.this.arn
  policy = data.aws_iam_policy_document.this.json
}



data "aws_iam_policy_document" "sns" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]

    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "cloudwatch.amazonaws.com"
      ]
    }

    resources = [
      "*",
    ]

    sid = "Allow_Services"
  }

  statement {
    actions = [
      "kms:*"
    ]

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = [
      "*",
    ]

    sid = "Enable Account"
  }

}


resource "aws_kms_key" "this" {
  description = "KMS Key used to encrypt SNS topic"
  key_usage   = "ENCRYPT_DECRYPT"
  is_enabled  = true
  policy      = data.aws_iam_policy_document.sns.json
}


resource "aws_kms_alias" "this" {
  name          = "alias/${var.name}-${var.env}"
  target_key_id = aws_kms_key.this.key_id
  depends_on = [
    aws_kms_key.this
  ]
}


data "aws_iam_policy_document" "this" {

  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudwatch.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.this.arn,
    ]

  }
}

resource "aws_sns_topic_subscription" "this" {
  topic_arn              = aws_sns_topic.this.arn
  protocol               = "email"
  endpoint               = var.endpoint
  endpoint_auto_confirms = true
}
