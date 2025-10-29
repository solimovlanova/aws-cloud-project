# VPN Server Outputs
output "vpn_server_public_ip" {
  description = "Public IP address of the VPN server"
  value       = var.create_vpn_server ? aws_instance.vpn_server[0].public_ip : null
}

output "vpn_server_instance_id" {
  description = "Instance ID of the VPN server"
  value       = var.create_vpn_server ? aws_instance.vpn_server[0].id : null
}
