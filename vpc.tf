resource "aws_vpc" "zg628t-todo-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "zg628t-todo-vpc"
  }
}

resource "aws_internet_gateway" "zg628t-todo-igw" {
  vpc_id = aws_vpc.zg628t-todo-vpc.id

  tags = {
    Name = "zg628t-todo-igw"
  }
}

resource "aws_subnet" "zg628t-todo-public-subnet" {
 count      = length(var.zg628t-todo-public-subnet-cidrs)
 vpc_id     = aws_vpc.zg628t-todo-vpc.id
 cidr_block = element(var.zg628t-todo-public-subnet-cidrs, count.index)
 availability_zone = element(var.zg628t-todo-azs, count.index)
 
 tags = {
   Name = "zg628t-todo-public-subnet-${count.index + 1}"
 }
}
 
resource "aws_subnet" "zg628t-todo-private-subnet" {
 count      = length(var.zg628t-todo-private-subnet-cidrs)
 vpc_id     = aws_vpc.zg628t-todo-vpc.id
 cidr_block = element(var.zg628t-todo-private-subnet-cidrs, count.index)
 availability_zone = element(var.zg628t-todo-azs, count.index)

 tags = {
   Name = "zg628t-todo-private-subnet-${count.index + 1}"
 }
}



# Nat gateway
resource "aws_eip" "g628t-todo-eip" {
  vpc = true

  tags = {
    Name = "g628t-todo-eip"
  }
}

resource "aws_nat_gateway" "g628t-todo-nat" {
  allocation_id = aws_eip.g628t-todo-eip.id
  subnet_id      = aws_subnet.zg628t-todo-public-subnet[0].id

  tags = {
    Name = "g628t-todo-nat"
  }

  depends_on = [aws_internet_gateway.zg628t-todo-igw]
}

resource "aws_route_table" "zg628t-todo-public-rt" {
 vpc_id = aws_vpc.zg628t-todo-vpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.zg628t-todo-igw.id
 }
 
 tags = {
   Name = "zg628t-todo-public-rt"
 }
}

resource "aws_route_table" "zg628t-todo-private-rt" {
  vpc_id = aws_vpc.zg628t-todo-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.g628t-todo-nat.id
  }

  tags = {
    Name = "zg628t-todo-private-rt"
  }
}


resource "aws_route_table_association" "zg628t-todo-private-rta" {
  count          = length(aws_subnet.zg628t-todo-private-subnet)
  subnet_id      = aws_subnet.zg628t-todo-private-subnet[count.index].id
  route_table_id = aws_route_table.zg628t-todo-private-rt.id
}



resource "aws_route_table_association" "zg628t-todo-public-rta" {
  count          = length(aws_subnet.zg628t-todo-public-subnet)
  subnet_id      = aws_subnet.zg628t-todo-public-subnet[count.index].id
  route_table_id = aws_route_table.zg628t-todo-public-rt.id
}


# EKS Cluster Security Group
resource "aws_security_group" "zg628t-todo-eks-cluster-sg" {
  name        = "zg628t-todo-eks-cluster-sg"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.zg628t-todo-vpc.id
}

resource "aws_security_group_rule" "zg628t-todo-eks-cluster-inbound-sgr" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.zg628t-todo-eks-cluster-sg.id
  source_security_group_id = aws_security_group.zg628t-todo-eks-worker-sg.id
  to_port                  = 443
  type                     = "ingress"
}

resource "aws_security_group_rule" "zg628t-todo-eks-cluster_outbound-sgr" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.zg628t-todo-eks-cluster-sg.id
  source_security_group_id = aws_security_group.zg628t-todo-eks-worker-sg.id
  to_port                  = 65535
  type                     = "egress"
}


# EKS Node Security Group
resource "aws_security_group" "zg628t-todo-eks-worker-sg" {
  name        = "zg628t-todo-eks-worker-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.zg628t-todo-vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "zg628t-todo-eks-worker-internal-sgr" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.zg628t-todo-eks-worker-sg.id
  source_security_group_id = aws_security_group.zg628t-todo-eks-worker-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "zg628t-todo-eks-worker-pod-inbound-sgr" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.zg628t-todo-eks-worker-sg.id
  source_security_group_id = aws_security_group.zg628t-todo-eks-cluster-sg.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "nodzg628t-todo-eks-worker-pod-outbound-sgr" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.zg628t-todo-eks-worker-sg.id
  source_security_group_id = aws_security_group.zg628t-todo-eks-cluster-sg.id
  to_port                  = 65535
  type                     = "egress"
}
