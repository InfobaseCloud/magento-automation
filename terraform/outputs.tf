################################################################################
# Account details
################################################################################

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

################################################################################
# AWS REGION
################################################################################

output "region" {
  value = data.aws_region.current.name
}

################################################################################
# instances
################################################################################

output "instance_ids" {
  value = try(var.instance_ids, null)
}

################################################################################
# sns
################################################################################

output "sns" {
  value = try(aws_sns_topic.this.id, null)
}

output "sns_arn" {
  value = try(aws_sns_topic.this.arn, null)
}

################################################################################
# Cloudwatch
################################################################################

output "cloudwatch_alarm" {
  value = { for k, v in aws_cloudwatch_metric_alarm.system_failure : k => v.arn }
}

################################################################################
# KMS
################################################################################

output "kms" {
  value = try(aws_kms_key.this.arn, null)
}

