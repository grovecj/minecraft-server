terraform {
  required_version = ">= 1.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

# Look up the SSH key
data "digitalocean_ssh_key" "main" {
  name = var.ssh_key_name
}

# Create the Minecraft server droplet
resource "digitalocean_droplet" "minecraft" {
  name     = var.droplet_name
  region   = var.region
  size     = var.size
  image    = "ubuntu-24-04-x64"
  ssh_keys = [data.digitalocean_ssh_key.main.id]
  tags     = ["minecraft"]

  user_data = templatefile("${path.module}/cloud-init.yml", {
    docker_compose = file("${path.module}/../docker-compose.yml")
  })

  lifecycle {
    # Prevent accidental destruction of the server
    prevent_destroy = true
  }
}

# Firewall
resource "digitalocean_firewall" "minecraft" {
  name        = "minecraft-firewall"
  droplet_ids = [digitalocean_droplet.minecraft.id]

  # SSH
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Minecraft Java Edition
  inbound_rule {
    protocol         = "tcp"
    port_range       = "25565"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Minecraft Bedrock Edition (GeyserMC)
  inbound_rule {
    protocol         = "udp"
    port_range       = "19132"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # BlueMap web map
  inbound_rule {
    protocol         = "tcp"
    port_range       = "8100"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow all outbound
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# DNS record: minecraft.cartergrove.me -> droplet IP
resource "digitalocean_record" "minecraft" {
  domain = var.domain
  type   = "A"
  name   = var.subdomain
  value  = digitalocean_droplet.minecraft.ipv4_address
  ttl    = 300
}
