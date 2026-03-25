# ECS Clusters
resource "aws_ecs_cluster" "primary" {
  provider = aws.primary
  name     = "${var.project_name}-primary-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster" "secondary" {
  provider = aws.secondary
  name     = "${var.project_name}-secondary-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}



# --- Primary Task Definitions & Services ---
resource "aws_ecs_task_definition" "primary_backend" {
  provider                 = aws.primary
  family                   = "${var.project_name}-primary-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = "${aws_ecr_repository.backend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    environment = [
      { name = "DATABASE_URL", value = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.primary.endpoint}/${var.project_name}" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-v2"
        "awslogs-region"        = var.primary_region
        "awslogs-stream-prefix" = "backend"
      }
    }
  }])
}

resource "aws_ecs_service" "primary_backend" {
  provider        = aws.primary
  name            = "${var.project_name}-primary-backend-svc"
  cluster         = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.primary_backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.primary_private[*].id
    security_groups  = [aws_security_group.primary_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.primary_backend.arn
    container_name   = "backend"
    container_port    = 3000
  }
}

resource "aws_ecs_task_definition" "primary_frontend" {
  provider                 = aws.primary
  family                   = "${var.project_name}-primary-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${aws_ecr_repository.frontend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-v2"
        "awslogs-region"        = var.primary_region
        "awslogs-stream-prefix" = "frontend"
      }
    }
  }])
}

resource "aws_ecs_service" "primary_frontend" {
  provider        = aws.primary
  name            = "${var.project_name}-primary-frontend-svc"
  cluster         = aws_ecs_cluster.primary.id
  task_definition = aws_ecs_task_definition.primary_frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.primary_private[*].id
    security_groups  = [aws_security_group.primary_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.primary_frontend.arn
    container_name   = "frontend"
    container_port    = 80
  }
}

# --- Secondary Task Definitions & Services ---
resource "aws_ecs_task_definition" "secondary_backend" {
  provider                 = aws.secondary
  family                   = "${var.project_name}-secondary-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "backend"
    image     = "${aws_ecr_repository.backend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 3000
      hostPort      = 3000
    }]
    environment = [
      { name = "DATABASE_URL", value = "postgres://${var.db_username}:${var.db_password}@${aws_db_instance.primary.endpoint}/postgres" }
    ]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-secondary-v2"
        "awslogs-region"        = var.secondary_region
        "awslogs-stream-prefix" = "backend"
      }
    }
  }])
}

resource "aws_ecs_service" "secondary_backend" {
  provider        = aws.secondary
  name            = "${var.project_name}-secondary-backend-svc"
  cluster         = aws_ecs_cluster.secondary.id
  task_definition = aws_ecs_task_definition.secondary_backend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.secondary_private[*].id
    security_groups  = [aws_security_group.secondary_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.secondary_backend.arn
    container_name   = "backend"
    container_port    = 3000
  }
}

resource "aws_ecs_task_definition" "secondary_frontend" {
  provider                 = aws.secondary
  family                   = "${var.project_name}-secondary-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([{
    name      = "frontend"
    image     = "${aws_ecr_repository.frontend.repository_url}:latest"
    essential = true
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = "/ecs/${var.project_name}-secondary-v2"
        "awslogs-region"        = var.secondary_region
        "awslogs-stream-prefix" = "frontend"
      }
    }
  }])
}

resource "aws_ecs_service" "secondary_frontend" {
  provider        = aws.secondary
  name            = "${var.project_name}-secondary-frontend-svc"
  cluster         = aws_ecs_cluster.secondary.id
  task_definition = aws_ecs_task_definition.secondary_frontend.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.secondary_private[*].id
    security_groups  = [aws_security_group.secondary_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.secondary_frontend.arn
    container_name   = "frontend"
    container_port    = 80
  }
}
