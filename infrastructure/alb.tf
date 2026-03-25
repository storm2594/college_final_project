# Primary ALB
resource "aws_lb" "primary" {
  provider           = aws.primary
  name               = "${var.project_name}-primary-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.primary_alb_sg.id]
  subnets            = aws_subnet.primary_public[*].id
  tags               = { Name = "Primary ALB" }
}

resource "aws_lb_target_group" "primary_frontend" {
  provider    = aws.primary
  name        = "${var.project_name}-pri-fe-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.primary.id
  target_type = "ip"
  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "primary_backend" {
  provider    = aws.primary
  name        = "${var.project_name}-pri-be-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.primary.id
  target_type = "ip"
  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "primary_http" {
  provider          = aws.primary
  load_balancer_arn = aws_lb.primary.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary_frontend.arn
  }
}

resource "aws_lb_listener_rule" "primary_api" {
  provider     = aws.primary
  listener_arn = aws_lb_listener.primary_http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary_backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

# Secondary ALB
resource "aws_lb" "secondary" {
  provider           = aws.secondary
  name               = "${var.project_name}-secondary-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.secondary_alb_sg.id]
  subnets            = aws_subnet.secondary_public[*].id
  tags               = { Name = "Secondary ALB" }
}

resource "aws_lb_target_group" "secondary_frontend" {
  provider    = aws.secondary
  name        = "${var.project_name}-sec-fe-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.secondary.id
  target_type = "ip"
  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "secondary_backend" {
  provider    = aws.secondary
  name        = "${var.project_name}-sec-be-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.secondary.id
  target_type = "ip"
  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "secondary_http" {
  provider          = aws.secondary
  load_balancer_arn = aws_lb.secondary.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.secondary_frontend.arn
  }
}

resource "aws_lb_listener_rule" "secondary_api" {
  provider     = aws.secondary
  listener_arn = aws_lb_listener.secondary_http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.secondary_backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
