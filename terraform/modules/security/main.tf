resource "aws_security_group" "bastion" {
  name_prefix = "kubeadm-bastion-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.ssh_allowed_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "bastion_out" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "nodes" {
  name_prefix = "kubeadm-nodes-"
  vpc_id      = var.vpc_id

  tags = {
    Name = "kubeadm-nodes-sg"
  }
}

# SSH to nodes only from the bastion, not from the internet.
resource "aws_vpc_security_group_ingress_rule" "nodes_ssh" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.bastion.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}

# Allow private traffic between Kubernetes nodes (required for later setup).
resource "aws_vpc_security_group_ingress_rule" "nodes_each_other" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "nodes_out" {
  security_group_id = aws_security_group.nodes.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
