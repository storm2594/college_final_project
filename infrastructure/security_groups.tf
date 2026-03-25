# Primary Security Groups
resource "aws_security_group" "primary_alb_sg" {
  provider    = aws.primary
  name        = "${var.project_name}-primary-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.primary.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "primary_ecs_sg" {
  provider    = aws.primary
  name        = "${var.project_name}-primary-ecs-sg"
  description = "Allow traffic from ALB to ECS"
  vpc_id      = aws_vpc.primary.id

  ingress {
    description     = "Traffic from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.primary_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "primary_rds_sg" {
  provider    = aws.primary
  name        = "${var.project_name}-primary-rds-sg"
  description = "Allow DB traffic from ECS"
  vpc_id      = aws_vpc.primary.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.primary_ecs_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Secondary Security Groups
resource "aws_security_group" "secondary_alb_sg" {
  provider    = aws.secondary
  name        = "${var.project_name}-secondary-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.secondary.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "secondary_ecs_sg" {
  provider    = aws.secondary
  name        = "${var.project_name}-secondary-ecs-sg"
  description = "Allow traffic from ALB to ECS"
  vpc_id      = aws_vpc.secondary.id

  ingress {
    description     = "Traffic from ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.secondary_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "secondary_rds_sg" {
  provider    = aws.secondary
  name        = "${var.project_name}-secondary-rds-sg"
  description = "Allow DB traffic from ECS"
  vpc_id      = aws_vpc.secondary.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.secondary_ecs_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
