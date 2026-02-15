# Terraform deployment (minimal)

This Terraform deploys a single EC2 instance in the **default VPC** and uses **user_data** to install Docker and run the provided `docker-compose.yml` stack:
- `itzg/minecraft-server` (Minecraft + RCON)
- `itzg/rcon` (RCON web admin)
- `itzg/bungeecord` (proxy)
- `itzg/mc-backup` (backups)

## Ports opened
- 25565/tcp (Minecraft)
- 25575/tcp (RCON)
- 4326/tcp (RCON web admin)
- 22/tcp (SSH, restricted by `allowed_ssh_cidr`)

## Notes
- Set `allowed_ssh_cidr` to your IP/32.
- Set `key_name` if you want SSH access.
- Change default passwords (`rcon_password`, `rcon_web_password`).
