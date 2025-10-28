resource "aws_db_instance" "default" {
  count                        = var.create_db_instance_postgres ? 1 : 0
  allocated_storage            = 20
  db_name                      = ""
  engine                       = "postgres"
  engine_version               = "17.4"
  instance_class               = "db.t3.micro"
  username                     = "postgres"
  password                     = var.db_password
  parameter_group_name         = "default.postgres17"
  skip_final_snapshot          = true
  storage_encrypted            = true
  publicly_accessible          = true
  performance_insights_enabled = true
  max_allocated_storage        = 20
  copy_tags_to_snapshot        = true
  apply_immediately            = true
  vpc_security_group_ids       = [aws_security_group.postgres[0].id]
}


resource "aws_security_group" "postgres" {
  count       = var.create_db_instance_postgres ? 1 : 0
  name        = "posgres-sg"
  description = "sg for postgres RDS"
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "jump_host_postgres" {
  count                    = var.create_db_instance_postgres && var.create_jump_host ? 1 : 0
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  type                     = "ingress"
  security_group_id        = aws_security_group.postgres[0].id
  source_security_group_id = aws_security_group.jump_host[0].id
}

