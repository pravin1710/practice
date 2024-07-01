resource "aws_vpc" "aws-vpc" { //creates vpc  
  cidr_block           = "10.11.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_environment
  }
}



resource "aws_subnet" "private" { //creates private subnets with cidr block from tfvars
  vpc_id            = aws_vpc.aws-vpc.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "${var.app_name}-private-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
  depends_on = [aws_vpc.aws-vpc]
}

resource "aws_subnet" "public" { //creates public subnets with cidr block from tfvars
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  count                   = length(var.public_subnets)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.app_name}-public-subnet-${count.index + 1}"
    Environment = var.app_environment
  }
  depends_on = [aws_vpc.aws-vpc]
}

resource "aws_internet_gateway" "aws-igw" { //creates internet getway 
  vpc_id = aws_vpc.aws-vpc.id
  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_environment
  }
  depends_on = [aws_vpc.aws-vpc]

}
resource "aws_route_table" "private" { //creates 2 route table for private subnet and associates with nat-gateway
  count  = length(var.private_subnets)
  vpc_id = aws_vpc.aws-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name        = "${var.app_name}-private-route-table-${count.index + 1}"
    Environment = var.app_environment
  }
  depends_on = [aws_subnet.private]
}

resource "aws_nat_gateway" "nat" { //creates two nat-gateway 
  count         = length(var.public_subnets)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_subnet.public]

}

resource "aws_eip" "nat" { //creates elastic ip
  count      = length(var.public_subnets)
  depends_on = [aws_subnet.public]
}

resource "aws_route_table_association" "private" { //route-table-association with private subnets
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  depends_on     = [aws_route_table.private]
}


resource "aws_route_table" "public" { //creates route table for public subnets
  vpc_id = aws_vpc.aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws-igw.id //routes to internet gateway 
  }


  tags = {
    Name        = "${var.app_name}-routing-table-public"
    Environment = var.app_environment
  }
  depends_on = [aws_subnet.public]
}


resource "aws_route_table_association" "public" { //route table association with public subnets
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = element(aws_route_table.public.*.id, count.index)
  depends_on     = [aws_route_table.public]
}


resource "aws_security_group" "service_security_group" {
  vpc_id = aws_vpc.aws-vpc.id

  ingress { // Inbound rules which allows request from port 80 to vpc
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress { // Outbound rules which allows traffic out from vpc to anywhere
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress { // Inbound rules which allows request from port 80 to vpc
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress { // Outbound rules which allows traffic out from vpc to anywhere
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress { // Inbound rules which allows traffic from port 443 to vpc
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  egress { // Outbound rules which allows traffic out from vpc to anywhere
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name        = "${var.app_name}-service-sg"
    Environment = var.app_environment
  }
  depends_on = [aws_vpc.aws-vpc]
}
