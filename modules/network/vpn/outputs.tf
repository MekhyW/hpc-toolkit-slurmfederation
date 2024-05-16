output "vpn_gateway_ip_address" {
  value = google_compute_vpn_gateway.vpn_gateway.ip_address
}

output "vpn_tunnel_name" {
  value = google_compute_vpn_tunnel.vpn_tunnel.name
}