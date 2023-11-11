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
  value = lookup(lookup(module.public_subnets, "public", null), "subnet_ids", null)[0]
  //value = module.public_subnets["public"]["subnet_ids"][0]
}

#out = {
#  "main" = { -----this is from root module
#    "public_subnet_ids" = { ===from vpc module
#      "public" = { ---from public_subnets module
#        "subnet_ids" = [
#          "subnet-00adbe860e3616783",
#          "subnet-0a473f1120f11aaf8",
#        ]
#      }
#    }
#    "vpc_id" = "vpc-0496ca9654fa61564"
#    "vpc_peering_connection_id" = "pcx-02e186f1ce4a8d3cf"
#  }
#}