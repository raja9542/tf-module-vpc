output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.peer.id
}

output "public_subnet_ids" {
  value = module.public_subnets
}

output "one_subnet_id" {
  value = module.public_subnets["public"]["subnet_ids"][0]
}