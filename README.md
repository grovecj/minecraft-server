# Minecraft Server

Paper Minecraft server running on Digital Ocean, managed with Terraform and Docker.

- **Server**: `minecraft.cartergrove.me`
- **Bedrock**: `minecraft.cartergrove.me` port `19132`
- **World Map**: https://minecraft.cartergrove.me

## Infrastructure

- **Droplet**: s-2vcpu-4gb ($24/mo) in nyc1
- **OS**: Ubuntu 24.04
- **Server**: Paper (latest) via [itzg/minecraft-server](https://github.com/itzg/docker-minecraft-server)
- **Reverse proxy**: Caddy (auto-TLS for BlueMap web map)
- **Firewall**: SSH (22), Java MC (25565), Bedrock/UDP (19132), HTTP/HTTPS (80/443)
- **Backups**: Daily world backup via cron, 7-day retention

## Deployment

### First-time setup

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your DO API token
terraform init
terraform apply
```

### Updating config

```bash
scp docker-compose.yml Caddyfile root@<DROPLET_IP>:/opt/minecraft/
ssh root@<DROPLET_IP> 'cd /opt/minecraft && docker compose down && docker compose up -d'
```

### Useful commands (on the droplet)

```bash
docker compose logs -f minecraft    # Watch server logs
docker compose logs -f --tail 100   # Last 100 lines
docker exec minecraft rcon-cli      # Server console
docker compose down                 # Stop server
docker compose up -d                # Start server
docker compose pull && docker compose up -d  # Update container image
```

### Resizing

1. `docker compose down` on the droplet
2. DO Dashboard > Droplets > Resize > pick new size
3. `docker compose up -d`

## Plugins

### EssentialsX — Core Commands

Teleportation, messaging, and quality-of-life commands.

**Teleportation:**
- `/sethome` — save your current location
- `/home` — teleport back to it
- `/tpa <player>` — request to teleport to someone
- `/tpaccept` / `/tpdeny` — respond to requests
- `/spawn` — go to world spawn
- `/setspawn` — set the world spawn (admin)
- `/warp <name>` / `/setwarp <name>` — named teleport points

**Communication:**
- `/msg <player> <message>` — private message
- `/r <message>` — reply to last message
- `/mail send <player> <message>` — offline mail

**Utility:**
- `/back` — return to last location or death point
- `/afk` — mark yourself as away
- `/near` — show nearby players
- `/seen <player>` — when a player was last online

### LuckPerms — Permissions

Controls who can do what. Give yourself admin:

```
/lp user <name> permission set * true
```

**Commands:**
- `/lp user <name> permission set <perm> true` — grant a permission
- `/lp user <name> parent set <group>` — add user to a group
- `/lp creategroup <name>` — create a group (e.g. "moderator")
- `/lp editor` — opens a web editor in your browser (easiest way to manage permissions)

### WorldEdit — Building Tools

Use a wooden axe (`//wand`) to select regions. Left-click = pos 1, right-click = pos 2.

- `//wand` — get the selection tool
- `//set <block>` — fill selection with a block
- `//replace <from> <to>` — swap blocks in selection
- `//copy` / `//paste` — clipboard operations
- `//undo` / `//redo` — undo mistakes
- `//sphere <block> <radius>` — create a sphere
- `//drain <radius>` — remove water/lava

### WorldGuard — Area Protection

Protects areas from griefing. Uses WorldEdit selections.

```
//wand
(select two corners around an area)
/rg define <name>
/rg flag <name> pvp deny
/rg addmember <name> <player>
```

**Common flags:** `pvp`, `mob-spawning`, `creeper-explosion`, `tnt`, `use`, `chest-access`

### CoreProtect — Block Logging & Rollback

Tracks every block change. Essential for investigating griefing.

- `/co inspect` — toggle inspect mode, click blocks to see history
- `/co lookup u:<player> t:<time>` — search actions (e.g. `u:Steve t:1h`)
- `/co rollback u:<player> t:<time>` — undo a player's changes
- `/co restore u:<player> t:<time>` — re-apply rolled-back changes

### BlueMap — Web Map

Live 3D map at https://minecraft.cartergrove.me.

- `/bluemap status` — render progress
- `/bluemap render` — force a full render
- `/bluemap pause` / `/bluemap resume` — pause rendering if causing lag

### ViaVersion

Allows players on slightly different Minecraft versions to connect. No configuration needed.

### GeyserMC + Floodgate

Lets Bedrock Edition players (phone, console, Windows 10) join on port `19132`. Bedrock players appear with a `*` prefix. No configuration needed.
