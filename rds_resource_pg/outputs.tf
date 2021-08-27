output "rds_hostname" {
  description = "RDS instance hostname"
  value       = aws_db_instance.dgp-pg-devl-db.address
  sensitive   = false
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.dgp-pg-devl-db.port
  sensitive   = false
}

output "rds_username" {
  description = "RDS instance root username"
  value       = aws_db_instance.dgp-pg-devl-db.username
  sensitive   = false
}
