resource "aws_db_subnet_group" "db_subnets" {
  name       = "usage-db-subnets-tf"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-usage-sg-tf"
  vpc_id = aws_vpc.usage_vpc.id
}

resource "aws_security_group" "lambda_sg" {
  name   = "lambda-usage-sg-tf"
  vpc_id = aws_vpc.usage_vpc.id
}

resource "aws_security_group_rule" "lambda_outbound_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lambda_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_lambda_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

resource "aws_db_instance" "usage_db" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.6"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  db_name                = var.db_name
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnets.name
}

