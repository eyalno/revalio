#############################################
# RDS Subnet Group
#############################################

resource "aws_db_subnet_group" "db_subnets" {
  name       = "usage-db-subnets-tf"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = {
    Name = "usage-db-subnets"
  }
}

#############################################
# Security Groups
#############################################

resource "aws_security_group" "rds_sg" {
  name        = "rds-usage-sg-tf"
  description = "Allow Lambda access to PostgreSQL"
  vpc_id      = aws_vpc.usage_vpc.id

  tags = {
    Name = "rds-usage-sg"
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda-usage-sg-tf"
  description = "Lambda outbound access + DB connectivity"
  vpc_id      = aws_vpc.usage_vpc.id

  tags = {
    Name = "lambda-usage-sg"
  }
}

#############################################
# SG Rules: Lambda → Internet and Lambda → RDS
#############################################

# Lambda outbound to NAT for internet access
resource "aws_security_group_rule" "lambda_outbound_all" {
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda_sg.id
}

# Allow Lambda to reach RDS on port 5432
resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

#############################################
# RDS PostgreSQL Instance
#############################################

resource "aws_db_instance" "usage_db" {
  identifier              = "usage-tracking-prod-db"
  allocated_storage       = 20
  engine                  = "postgres"
  engine_version          = "17.6"
  instance_class          = "db.t3.micro"

  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name

  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]

  publicly_accessible     = false
  skip_final_snapshot     = true

  tags = {
    Name = "usage-tracking-rds"
  }
}