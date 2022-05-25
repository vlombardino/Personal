## Docker Seedbox Install
> Ubuntu server 22.04

### Docker install
```
sudo apt update && apt upgrade

sudo apt install apt-transport-https ca-certificates curl software-properties-common

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install docker-ce docker-ce-cli containerd.io docker-compose
```

### If Needed Get Latest Docker Compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose
```

### Check Installed Version
```
docker -v

docker-compose -v
```

### Allow user to configure Docker
```
sudo usermod -aG docker $USER

sudo reboot
```

### Create folders
```
mkdir -p /home/box/docker/{filebrowser,jackett,nzbget,deluge,bazarr,sonarr,radarr}/config

mkdir -p /home/box/downloads/{completed/{movies,music,other,tv},incomplete,intermediate,nzb,queue,tmp,watch/{converted,storage,watch}}
```

### Create NFS Docker volume (synology)
```
docker volume create \
	--driver local \
	--opt type=nfs4 \
	--opt o=addr=192.168.1.80,rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14 \
	--opt device=:/volume3/PlexMedia/TV \
	tv

docker volume create \
	--driver local \
	--opt type=nfs4 \
	--opt o=addr=192.168.1.80,rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14 \
	--opt device=:/volume3/PlexMedia/Movies \
	movies

docker volume create \
	--driver local \
	--opt type=nfs4 \
	--opt o=addr=192.168.1.80,rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14 \
	--opt device=:/volume3/PlexMedia/Animation \
	animation
```

---

### Docker Containers
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
```
docker create \
	--name filebrowser \
	--user $(id -u):$(id -g) \
	-p 8080:8080 \
	-v /home:/data \
	-v /home/box/docker/filebrowser/config:/config \
	-e FB_BASEURL=/filebrowser \
	--restart unless-stopped \
	hurlenko/filebrowser
```
```
docker create \
	--name=gluetun \
	--device=/dev/net/tun:/dev/net/tun \
	--cap-add=NET_ADMIN \
	-e VPN_SERVICE_PROVIDER=nordvpn \
	-e OPENVPN_USER=vlombardino@gmail.com \
	-e OPENVPN_PASSWORD=VPNNord@20190513 \
	-e SERVER_REGIONS=Switzerland \
	-p 9117:9117 `#jackett` \
 	-p 8112:8112 `#Deluge` \
 	-p 6881:6881 `#Deluge` \
 	-p 6881:6881/udp `#Deluge` \
	--restart unless-stopped \
	qmcgaw/gluetun
```
```
docker create \
	--name=jackett \
	-e PUID=0 \
	-e PGID=0 \
	-e TZ=America/Los_Angeles \
	-e AUTO_UPDATE=true \
	--net=container:gluetun `#gluetun` \
	-v /home/box/docker/jackett/config:/config \
	-v /home/box/downloads/tmp:/downloads \
	--restart unless-stopped \
	lscr.io/linuxserver/jackett:latest
```
```
docker run -d \
 	--name=deluge \
 	-e PUID=0 \
 	-e PGID=0 \
 	-e TZ=America/Los_Angeles \
 	-e DELUGE_LOGLEVEL=error `#optional` \
	--net=container:gluetun `#gluetun` \
 	-v /home/box/docker/deluge/config:/config \
 	-v /home/box/downloads:/downloads \
 	--restart unless-stopped \
 	lscr.io/linuxserver/deluge:latest
```
```
docker create \
	--name=nzbget \
	-e PUID=0 \
	-e PGID=0 \
	-e TZ=America/Los_Angeles \
	-p 6789:6789 \
	-v /home/box/docker/nzbget/config:/config \
	-v /home/box/downloads:/downloads \
	--restart unless-stopped \
	lscr.io/linuxserver/nzbget:latest
```
```
docker create \
	--name=sonarr \
	-e PUID=0 \
	-e PGID=0 \
	-e TZ=America/Los_Angeles \
	-p 8989:8989 \
	-v /home/box/docker/sonarr/config:/config \
	-v /home/box/downloads:/downloads \
	-v tv:/tv \
	--restart unless-stopped \
	lscr.io/linuxserver/sonarr:latest
```
```
docker create \
	--name=radarr \
	-e PUID=0 \
	-e PGID=0 \
	-e TZ=America/Los_Angeles \
	-p 7878:7878 \
	-v /home/box/docker/radarr/config:/config \
	-v /home/box/downloads:/downloads \
	-v movies:/movies \
	-v animation:/animation \
	--restart unless-stopped \
	lscr.io/linuxserver/radarr:latest
```
```
docker create \
	--name=bazarr \
	-e PUID=0 \
	-e PGID=0 \
	-e TZ=America/Los_Angeles \
	-p 6767:6767 \
	-v /home/box/docker/bazarr/config:/config \
	-v tv:/tv \
	-v movies:/movies \
	-v animation:/animation \
	--restart unless-stopped \
	lscr.io/linuxserver/bazarr:latest
```
