resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,
    {Name = "${var.env}-vpc"}
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

# route vpc subnet into workstation vpc route table
resource "aws_route" "default-vpc" {
  route_table_id            = data.aws_vpc.default.main_route_table_id  #workstation default route table id
  destination_cidr_block    = var.cidr_block # 10.0.0.0/16
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    {Name = "${var.env}-igw"}
  )
}

#resource "aws_eip" "ngw-eip" {
#  domain   = "vpc"
#}
#
#resource "aws_nat_gateway" "ngw" {
#  count   = var.nat_gw ? 1 : 0
#  allocation_id = aws_eip.ngw-eip.id
#  subnet_id     = var.private_subnets.ids[0]
#
#  tags = merge(
#    local.common_tags,
#    {Name = "${var.env}-ngw"}
#  )
#}


