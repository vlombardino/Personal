## [Planka](https://github.com/plankanban/planka)
> Ubuntu 22.04 - Proxmox CT - Docker

---

### Allow Root Login Over SSH

```
nano /etc/ssh/sshd_config
```
> ####################ADD TEXT#################### \
> PermitRootLogin yes \
> ################################################
```
service ssh restart
```

---

### Docker Install
```
apt update && apt upgrade

apt install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt install docker-ce docker-ce-cli containerd.io docker-compose
```

### Check Installed Version
```
docker -v

docker-compose -v
```

### [Latest Docker Compose](https://github.com/docker/compose/releases) (If Needed)
```
curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose
```
---

### Docker Containers

> [Portainer](https://hub.docker.com/r/portainer/portainer-ce)
```
docker volume create portainer_data

docker run -d \
	-p 9000:9000 \
	-p 8000:8000 \
	--name portainer \
	--restart always \
	-v /var/run/docker.sock:/var/run/docker.sock \
	-v portainer_data:/data portainer/portainer-ce
```

> [Planka](https://github.com/plankanban/planka/blob/master/docker-compose.yml)

```
mkdir -p /home/docker/planka/{avatars,images,files,data}
```
```
version: '3'

services:
  planka:
    image: ghcr.io/plankanban/planka:latest
    command: >
      bash -c
        "for i in `seq 1 30`; do
          ./start.sh &&
          s=$$? && break || s=$$?;
          echo \"Tried $$i times. Waiting 5 seconds...\";
          sleep 5;
        done; (exit $$s)"
    restart: unless-stopped
    volumes:
      - /home/docker/planka/avatars:/app/public/user-avatars
      - /home/docker/planka/images:/app/public/project-background-images
      - /home/docker/planka/files:/app/private/attachments
    ports:
      - 3000:1337
    environment:
      - BASE_URL=http://192.168.1.17:3000
      - TRUST_PROXY=0
      - DATABASE_URL=postgresql://postgres@postgres/planka
      - SECRET_KEY=21228c58104280e266aa8cc53a041954c42c3d0f86f32668a9f5f0c26e9877bb935e9fb40357d12c083f6073f476e40ab98d927cfb1a5708a405a6691a733264
    depends_on:
      - postgres

  postgres:
    image: postgres:alpine
    restart: unless-stopped
    volumes:
      - /home/docker/planka/data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=planka
      - POSTGRES_HOST_AUTH_METHOD=trust
```

---

### Additional Notes

SECRET_KEY ```openssl rand -hex 64```

Default Login
> Username: demo@demo.demo \
> Password: demo
