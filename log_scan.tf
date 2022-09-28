locals {
  account_id     = data.aws_caller_identity.current.account_id
  logs = ["/ecs/dataplatform-ingest-task", "/ecs/hello-world"]
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_metric_filter" "error-we-care-about-metric-filter" {
  count                     = length(local.logs)
  name           = "OurMetricFilter-${local.logs[count.index]}"
  log_group_name = local.logs[count.index]
  pattern        = "ERROR_WE_CARE_ABOUT"
  metric_transformation {
    name      = "ErrorWeCareAboutMetric"
    namespace = "ImportantMetrics"
    value     = "1"
  }
}


resource "aws_cloudwatch_metric_alarm" "error-we-care-about-alarm" {
    count                     = length(local.logs)
  alarm_name = "error-we-care-about-${local.logs[count.index]}"
  metric_name         = aws_cloudwatch_log_metric_filter.error-we-care-about-metric-filter[count.index].name
  threshold           = "0"
  statistic           = "Sum"
  comparison_operator = "GreaterThanThreshold"
  datapoints_to_alarm = "1"
  evaluation_periods  = "1"
  period              = "60"
  namespace           = "ImportantMetrics"
  alarm_actions       =  [aws_sns_topic.ecs_alerts.arn]
}