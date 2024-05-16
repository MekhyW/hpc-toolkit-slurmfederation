variable "region" {
  description = "The region where the VPN will be created."
  default = "us-central1"
}

variable "network" {
  description = "The name of the VPC network to which the VPN will be attached."
  default = "default"
}

variable "project_id" {
  description = "The ID of the project where the VPN will be created."
}

variable "on_premise_ip_range" {
  description = "The CIDR range of the on-premise network."
}

variable "shared_secret" {
  description = "The pre-shared key for the VPN connection."
}

variable "vpn_gateway_name" {
  description = "The name of the VPN gateway."
  default = "vpn-gateway"
}

variable "vpn_tunnel_name" {
  description = "The name of the VPN tunnel."
  default = "vpn-tunnel"
}