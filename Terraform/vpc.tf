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

  # Allow inbound traffic for specified ports
  dynamic "ingress" {
    for_each = var.zg628t-todo-eks-cluster-allowed-ports
    content {
      description = "Allow traffic on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.zg628t-todo-eks-cluster-allowed-cidr
    }
  }

  # Allow all outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "zg628t-todo-eks-cluster-sg"
  }
}




# EKS Node Security Group
resource "aws_security_group" "zg628t-todo-eks-worker-sg" {
  name        = "zg628t-todo-eks-worker-sg"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.zg628t-todo-vpc.id

 # Dynamic block to allow inbound traffic for specified ports
  dynamic "ingress" {
    for_each = var.zg628t-todo-eks-worker-allowed-ports
    content {
      description = "Allow traffic on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.zg628t-todo-eks-cluster-allowed-cidr
    }
  }

  # Ingress rule to allow inbound traffic for the NodePort range (30000-32767)
  ingress {
    description = "Allow NodePort services"
    from_port   = var.zg628t-todo-eks-worker-allowed-node-ports["from"]
    to_port     = var.zg628t-todo-eks-worker-allowed-node-ports["to"]
    protocol    = "tcp"
    cidr_blocks = var.zg628t-todo-eks-cluster-allowed-cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

r