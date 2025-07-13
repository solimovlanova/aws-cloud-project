resource "aws_db_instance" "default" {
  allocated_storage    = 20
  db_name              = ""
  engine               = "postgres"
  engine_version       = "17.4"
  instance_class       = "db.t3.micro"
  username             = "postgres"
  password             = var.db_password
  parameter_group_name = "default.postgres17"
  skip_final_snapshot  = true
  storage_encrypted = true  
  publicly_accessible = true 
  performance_insights_enabled = true 
  max_allocated_storage = 20  
  copy_tags_to_snapshot = true 
  apply_immediately  = true             
}

import {
  to = aws_db_instance.default
  id = "database-1"
}