module "subnets" {
  source           = "./subnets"

  default_vpc_id             = var.default_vpc_id
  env                        = var.env
  availability_zone          = var.availability_zone

  for_each                   = var.subnets
  cidr_block                 = each.value.cidr_block
  name                       = each.value.name
  # look for each.value for internet_gw if it is there it will give true if not default value false
  internet_gw                = lookup(each.value, "internet_gw ", false ) ? aws_internet_gateway.gw.id : null
#  nat_gw                    = lookup(each.value, "nat_gw", false )

  vpc_id                     = aws_vpc.main.id
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
  common_tags                = local.common_tags

}