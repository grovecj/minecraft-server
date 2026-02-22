variable "do_token" {
  description = "Digital Ocean API token"
  type        = string
  sensitive   = true
}

variable "droplet_name" {
  description = "Name of the droplet"
  type        = string
  default     = "minecraft-server"
}

variable "region" {
  description = "Digital Ocean region"
  type        = string
  default     = "nyc1"
}

variable "size" {
  description = "Droplet size slug"
  type        = string
  default     = "s-1vcpu-2gb"
}

variable "domain" {
  description = "Domain name"
  type        = string
  default     = "cartergrove.me"
}

variable "subdomain" {
  description = "Subdomain for the Minecraft server"
  type        = string
  default     = "minecraft"
}

variable "ssh_key_name" {
  description = "Name of the SSH key in Digital Ocean"
  type        = string
  default     = "1PASSWORD-DigitalOcean"
}
