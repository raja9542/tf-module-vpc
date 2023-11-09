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
  route_table_id            = aws_vpc.main.default_route_table_id # default route table id of workstation vpc
  destination_cidr_block    = "172.31.0.0/16" # default vpc ipv4 cidr (go to your vpcs there we can find it)
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}

resource "aws_route" "default" {
  route_table_id            = data.aws_vpc.default.main_route_table_id # id of main route table associated with created VPC
  destination_cidr_block    = var.cidr_block # our cidr block [10.0.0.0/16]
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id

}