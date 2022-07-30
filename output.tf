output "vpc_id" {
  description = "ID of the vpc"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "lists of private subnets"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "lists of public subnets"
  value       = module.vpc.public_subnets
}