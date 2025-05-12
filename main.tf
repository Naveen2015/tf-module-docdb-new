resource "aws_docdb_subnet_group" "subnet" {
  name       = "${var.name}-${var.env}"
  subnet_ids = var.subnets

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-docdb"})

}

resource "aws_security_group" "sg" {
  name        = "${var.name}-${var.env}-sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id
  ingress {
    description = "DOCDB"
    from_port        = var.port_no
    to_port          = var.port_no
    protocol         = "tcp"
    cidr_blocks      = var.allow_db_cidr

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-${var.env}-sg"})
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = "${var.name}-${var.env}-cluster"
  engine                  = "docdb"
  master_username         = data.aws_ssm_parameter.db_user.value
  master_password         = data.aws_ssm_parameter.db_pass.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  apply_immediately = true
  db_subnet_group_name = aws_docdb_subnet_group.subnet.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.pg.name
  engine_version = var.engine_version
  storage_encrypted = true
  kms_key_id = var.kms_arn
  port = var.port_no
  vpc_security_group_ids = [aws_security_group.sg.id]
  tags = merge(var.tags, { Name = "${var.name}-${var.env}-cluster"})
}

resource "aws_docdb_cluster_parameter_group" "pg" {
  family      = "docdb4.0"
  name        = "${var.name}-${var.env}-pg"
  description = "docdb cluster parameter group"
  tags = merge(var.tags, { Name = "${var.name}-${var.env}-pg"})

}
