# Subnet groups for RDS
resource "aws_db_subnet_group" "primary" {
  provider   = aws.primary
  name       = "${var.project_name}-primary-sng"
  subnet_ids = aws_subnet.primary_private[*].id
  tags       = { Name = "Primary DB Subnet Group" }
}

resource "aws_db_subnet_group" "secondary" {
  provider   = aws.secondary
  name       = "${var.project_name}-secondary-sng"
  subnet_ids = aws_subnet.secondary_private[*].id
  tags       = { Name = "Secondary DB Subnet Group" }
}

# Primary DB in us-east-1
resource "aws_db_instance" "primary" {
  provider                = aws.primary
  identifier              = "${var.project_name}-primary-db"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.primary.name
  vpc_security_group_ids  = [aws_security_group.primary_rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  backup_retention_period = 7
  multi_az                = false

  tags = { Name = "Primary Database" }
}


