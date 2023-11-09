resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,
    {Name = "${var.env}-vpc"}
    )
}

resource "aws_subnet" "main" {
  count      = length(var.subnets_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnets_cidr[count.index]

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-subnet-${count.index+1}"}
  )
}

resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = data.aws_caller_identity.current.account_id  # rather hardcoding we can get from datasources...data.tf (aws_caller_identity datasource)
  peer_vpc_id   = var.default_vpc_id # default vpc id or workstation vpc id
  vpc_id        = aws_vpc.main.id  # created vpc id
  auto_accept = true

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-peering"}
  )
}

# To route network traffic we need route network from both sides of vpc

resource "aws_route" "default" {
  route_table_id            = aws_vpc.main.default_route_table_id # created vpc route table id
  destination_cidr_block    = "172.31.0.0/16" # default vpc ipv4 cidr (go to your vpcs there we can find it)
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}

resource "aws_route" "igw" {
  route_table_id            = aws_vpc.main.default_route_table_id  # created vpc route table id
  destination_cidr_block    = "0.0.0.0/0" # default vpc ipv4 cidr (go to your vpcs there we can find it)
  gateway_id                =  aws_internet_gateway.igw.id

}


resource "aws_route" "default_vpc" {
  route_table_id            = data.aws_vpc.default.main_route_table_id # id of default route table associated -workstation vpc
  destination_cidr_block    = var.cidr_block # our cidr block [10.0.0.0/16]
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-igw"}
  )
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
  subnet_id = aws_subnet.main.*.id[0]

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