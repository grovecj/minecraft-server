output "droplet_ip" {
  description = "Public IP address of the Minecraft server"
  value       = digitalocean_droplet.minecraft.ipv4_address
}

output "server_address" {
  description = "Minecraft server address"
  value       = "${var.subdomain}.${var.domain}"
}

output "bluemap_url" {
  description = "BlueMap web map URL"
  value       = "http://${var.subdomain}.${var.domain}:8100"
}

output "ssh_command" {
  description = "SSH command to connect to the server"
  value       = "ssh root@${digitalocean_droplet.minecraft.ipv4_address}"
}
