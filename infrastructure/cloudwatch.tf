resource "aws_cloudwatch_dashboard" "main" {
  provider       = aws.primary
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.primary.name],
            [".", ".", ".", aws_ecs_cluster.secondary.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.primary_region
          title   = "ECS CPU Utilization (Primary & Secondary)"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "MemoryUtilization", "ClusterName", aws_ecs_cluster.primary.name],
            [".", ".", ".", aws_ecs_cluster.secondary.name]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.primary_region
          title   = "ECS Memory Utilization (Primary & Secondary)"
        }
      },
    ]
  })
}
