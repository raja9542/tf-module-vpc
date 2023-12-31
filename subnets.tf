module "public_subnets" {
  source           = "./subnets"

  default_vpc_id             = var.default_vpc_id
  env                        = var.env
  availability_zone          = var.availability_zone

  for_each                   = var.public_subnets
  cidr_block                 = each.value.cidr_block
  name                       = each.value.name
  # lookup function looks for a particular value if its there it gives that value else false
  internet_gw                = lookup(each.value, "internet_gw", false)
  nat_gw                    = lookup(each.value, "nat_gw", false)

  vpc_id                     = aws_vpc.main.id
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
  common_tags                = local.common_tags
  gateway_id                 = aws_internet_gateway.gw.id
  # to provide nat_gw_id here it will create cyclic problem b/c nat gateway creates only when internet gw creates..to avoid this problem we will declare null variable
}

module "private_subnets" {
  source           = "./subnets"

  default_vpc_id             = var.default_vpc_id
  env                        = var.env
  availability_zone          = var.availability_zone

  for_each                   = var.private_subnets
  cidr_block                 = each.value.cidr_block
  name                       = each.value.name
  # lookup function looks for a particular value if its there it gives that value else false
  internet_gw                = lookup(each.value, "internet_gw", false)
  nat_gw                     = lookup(each.value, "nat_gw", false)

  vpc_id                     = aws_vpc.main.id
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
  common_tags                = local.common_tags
  nat_gw_id                  = aws_nat_gateway.ngw.id
  # to provide gateway_id here it will create cyclic problem b/c nat gateway creates only when internet gw creates..to avoid this problem we will declare null variable
}