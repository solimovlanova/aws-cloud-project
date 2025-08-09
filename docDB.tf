resource "aws_docdb_cluster" "main" {
  count                  = var.create_db_instance_docdb ? 1 : 0
  cluster_identifier     = "docdb-cluster-demo"
  availability_zones     = ["us-west-2a"]
  master_username        = "admin"
  master_password        = var.db_password
  vpc_security_group_ids = [aws_security_group.jump_host.id]

}

resource "aws_docdb_cluster_instance" "cluster_instances" {
  count              = var.create_db_instance_docdb ? 1 : 0
  identifier         = "docdb-cluster-demo-${count.index}"
  cluster_identifier = aws_docdb_cluster.main[0].id
  instance_class     = "db.t3.medium"
}

resource "aws_security_group" "docdb" {
  name        = "docdb_sg"
  description = "this security group allows connection to db"
}

resource "aws_security_group_rule" "docdb_rule" {
  protocol                 = "tcp"
  type                     = "ingress"
  from_port                = 27017
  to_port                  = 27017
  security_group_id        = aws_security_group.docdb.id     #this is security group we attach this rule TO.
  source_security_group_id = aws_security_group.jump_host.id #This is security group we will traffic FROM.

}

