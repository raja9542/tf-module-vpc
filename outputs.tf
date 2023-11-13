output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.peer.id
}

output "public_subnet_ids" {
  value = module.public_subnets
}

output "private_subnet_ids" {
  value = module.private_subnets
}
// 1.output "private_subnet_ids" {
//  value = module.private_subnets
//}
#"main" = {
#  "private_subnet_ids" = {
#    "app" = {
#      "subnet_ids" = [
#        "subnet-080452a292443a09f",
#        "subnet-0e308cabf906cdeef",
#      ]
#    }
#    "db" = {
#      "subnet_ids" = [
#        "subnet-0b2d9c660a947d3ef",
#        "subnet-09b2aa79a5546cef2",
#      ]
#    }
#    "web" = {
#      "subnet_ids" = [
#        "subnet-034d11058070bd810",
#        "subnet-0bdb82984c8117ee2",
#      ]
#    }

#2.output "one_subnet_id" {
#  value = lookup(lookup(module.public_subnets, "public", null), "subnet_ids", null)[0]
#}


//
#    output "public_subnet_ids" {
#    value = module.public_subnets
#    }
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