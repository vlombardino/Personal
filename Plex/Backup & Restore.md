## Backup
```
sudo service plexmediaserver stop
sudo su
cd /var/lib/plexmediaserver
tar cf /home/$USER/PlexFullBackup.tar ./Library
```


## Restore
Install plex then start it once
```
sudo service plexmediaserver start
sudo service plexmediaserver stop
sudo su
mv /var/lib/plexmediaserver/Library /var/lib/plexmediaserver/Library.unused
tar -xf PlexFullBackup.tar -C /var/lib/plexmediaserver
cd /var/lib/plexmediaserver
chown -R plex:plex Library
sudo service plexmediaserver start
```
