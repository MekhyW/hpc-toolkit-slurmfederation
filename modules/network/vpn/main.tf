resource "google_compute_vpn_gateway" "vpn_gateway" {
  name    = var.vpn_gateway_name
  network = var.network
}

resource "google_compute_vpn_tunnel" "vpn_tunnel" {
  name           = var.vpn_tunnel_name
  peer_ip        = "on_premise_vpn_gateway_ip"
  shared_secret  = var.shared_secret
  target_vpn_gateway = google_compute_vpn_gateway.vpn_gateway.id
  local_traffic_selector = ["${var.on_premise_ip_range}"]
  remote_traffic_selector = ["0.0.0.0/0"] # or specify your remote network range
  shared_secret_hash = "${base64sha256(var.shared_secret)}"
}
