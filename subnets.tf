module "subnets" {
  source           = "./subnets"

  default_vpc_id             = var.default_vpc_id
  env                        = var.env
  availability_zone          = var.availability_zone

  for_each                   = var.subnets
  cidr_block                 = each.value.cidr_block
  name                       = each.value.name

  vpc_id                     = aws_vpc.main.id
  vpc_peering_connection_id  = aws_vpc_peering_connection.peer.id
  common_tags                = local.common_tags

}