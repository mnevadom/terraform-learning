

output "msk_arn" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "zookeeper_connect_string" {
  value = aws_msk_cluster.msk-devl.zookeeper_connect_string
}

output "bootstrap_brokers_tls" {
  description = "TLS connection host:port pairs"
  value       = aws_msk_cluster.msk-devl.bootstrap_brokers_tls
}