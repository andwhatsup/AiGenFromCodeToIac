# Terraform deployment (minimal)

This Terraform deploys a single EC2 instance in the **default VPC** and uses **Docker Compose** (via `user_data`) to run the services found in `docker-compose.yml`:

- `itzg/minecraft-server` (Minecraft)
- `itzg/rcon` (RCON web admin)
- `itzg/bungeecord` (proxy)
- `itzg/mc-backup` (backup)

## Notes
- Ports opened to the internet: 25565 (Minecraft), 25575 (RCON), 4326 (RCON web).
- For production, restrict security group ingress to trusted IPs.

## Usage
```bash
cd workspace/598622132/ai_basis_tf
terraform init
terraform apply
```
