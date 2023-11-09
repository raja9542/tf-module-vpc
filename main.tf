resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,
    {Name = "${var.env}-vpc"}
    )
}

resource "aws_subnet" "public" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets_cidr[count.index]

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-public-subnet-${count.index+1}"}
  )
}

resource "aws_subnet" "private" {
  count      = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnets_cidr[count.index]

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-private-subnet-${count.index+1}"}
  )
}

resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = data.aws_caller_identity.current.account_id  #The AWS account ID of the owner of the peer VPC rather hardcoding we can get from datasources...data.tf (aws_caller_identity datasource)
  peer_vpc_id   = var.default_vpc_id # default vpc id or workstation vpc id.. The ID of the VPC with which you are creating the VPC Peering Connection.
  vpc_id        = aws_vpc.main.id  # created vpc id
  auto_accept = true

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-peering"}
  )
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-igw"}
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
# peering connection route
  route {
    cidr_block = data.aws_vpc.default.cidr_block # workstation vpc cidr block ex:172.31.0.0/16
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-public-route-table"}
  )
}

resource "aws_route_table_association" "public-rt-assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.public.id
}

resource "aws_eip" "ngw-eip" {
   domain   = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = aws_subnet.public.*.id[0]

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-ngw"}
  )

#  depends_on = [aws_internet_gateway.igw]
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  # peering connection route
  route {
    cidr_block = data.aws_vpc.default.cidr_block # workstation vpc cidr block ex:172.31.0.0/16
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-private-route-table"}
  )
}

resource "aws_route_table_association" "private-rt-assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private.*.id[count.index]
  route_table_id = aws_route_table.private.id
}
 # route vpc subnet into workstation vpc route table
resource "aws_route" "default-vpc" {
  route_table_id            = data.aws_vpc.default.main_route_table_id  #workstation default route table id
  destination_cidr_block    = var.cidr_block # 10.0.0.0/16
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}


// create EC2

data "aws_ami" "centos8" {
  most_recent      = true
  name_regex       = "Centos-8-DevOps-Practice"
  owners           = ["973714476881"]

}
resource "aws_instance" "web" {
  ami           = data.aws_ami.centos8.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id = aws_subnet.private.*.id[0]

  tags = {
    Name = "test-centos8"
  }
}


resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id = aws_vpc.main.id


  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}