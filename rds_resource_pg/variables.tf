    variable "region" {
      default     = "eu-west-3"
      description = "AWS region"
    }

variable "db_password" {
  description = "RDS root user password"
  sensitive   = true
}
