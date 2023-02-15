#!/bin/bash

clear

############### Installation - Debian ################

##########################################################################
#####################    Change Information below    #####################

### Install hamachi ###
DOWNLOAD=http://files.hamachi.cc/linux/hamachi-0.9.9.9-20-lnx.tar.gz
FILE=hamachi-0.9.9.9-20-lnx.tar.gz
VERSION=hamachi-0.9.9.9-20-lnx

### ghamachi ###
DOWNLOADGHAMACI=http://purebasic.myftp.org/?filename=files/3/projects/hamachi/v.0.8.1/gHamachi_0.8.1.tar.gz
GHAMACHIICON=http://wonsheimlan.wo.funpic.de/hamachi.png
GHAMACHIMOVE=index.html\?filename\=files%2F3%2Fprojects%2Fhamachi%2Fv.0.8.1%2FgHamachi_0.8.1.tar.gz
GHAMACHIVERSION=gHamachi_0.8.1.tar.gz

### quamachi ###
#QUAMACHIDEBIAN=http://internap.dl.sourceforge.net/sourceforge/quamachi/quamachi_0.3.0-1_i386.deb
#aptitude install libqt4-core

############################################################

### Test for root user ###
function ROOTTEST
{

if [ "$(id -u)" != "0" ]; 
	then
	clear
	echo "You must be root to use this script!"
	echo
	read -p "Press enter to exit! " var		
	exit 1
fi

}

### Spacing ###
function SPACING
{

echo
echo "##########"
echo

}

### System HAMACHIUSERs ###
function SYSTEMHAMACHIUSERS
{

SPACING
cat /etc/passwd | grep "/bin/bash" | cut -d: -f1
SPACING
echo -n "Which system user will be using hamachi?: "
read HAMACHIUSER
SPACING

}

### Create /etc/init.d/tuncfg binary ###
function CREATETUNCFG
{

if [ ! -e /etc/init.d/tuncfg ];
	then
cat > /etc/init.d/tuncfg << "EOF"
#! bin/sh
# /etc/init.d/tuncfg
/sbin/tuncfg
EOF
	echo
	chmod 755 /etc/init.d/tuncfg
	update-rc.d tuncfg defaults
	echo
fi

}

### Remove /etc/init.d/tuncfg binary ###
function REMOVETUNCFG
{

if [ -e /etc/init.d/tuncfg ];
	then
	killall tuncfg
	sleep 1
	update-rc.d -f tuncfg remove
	sleep 1
	rm -f /etc/init.d/tuncfg
else
	echo "tuncfg has not been installed"
fi

}

### Install Hamachi ###
function INSTALLHAMACHI
{

if [ ! -e /usr/bin/hamachi ];
	then
	sleep 1
	echo "Installing required programs..."
	echo
	if [ `uname -m` = x86_64 ];
		then
		aptitude -y install build-essential ia32-libs upx-ucl-beta
	else
		aptitude -y install build-essential upx-ucl-beta
	fi
	echo
	sleep 1
	modprobe tun
	bash -c "echo tun >> /etc/modules"
	cd /home/$HAMACHIUSER
	wget $DOWNLOAD
	sleep 1
	tar -zxvf $FILE
	cd $VERSION
	sleep 1
	make install
	cd /usr/bin
	sleep 1
	upx -d hamachi
	sleep 1
	cd /home/$HAMACHIUSER
	rm $FILE
	rm -Rv $VERSION
	sleep 1
	echo
	echo "Configuring groups and create RSA keypair."
	/sbin/tuncfg
	sleep 1
	echo
	echo "Creating hamachi group..."
	groupadd hamachi
	sleep 1
	echo
	echo "Adding root to hamachi group..."
	gpasswd -a root hamachi
	sleep 1
	echo
	echo "Adding $HAMACHIUSER to hamachi group..."
	gpasswd -a $HAMACHIUSER hamachi
	sleep 1
	echo
	if [ $HAMACHIUSER = root ];
		then
		if [ ! -d /root/.hamachi ];
			then
			echo "Creating RSA keypair for $HAMACHIUSER..."
			sleep 1
			hamachi-init
		fi
	else
		if [ ! -d /home/$HAMACHIUSER/.hamachi ];
			then
			echo "Creating RSA keypair for $HAMACHIUSER..."
			sleep 1
			hamachi-init
			mv -f /root/.hamachi /home/$HAMACHIUSER
		fi
	fi
	sleep 1
	if [ $HAMACHIUSER = root ];
		then
		chown -R $HAMACHIUSER:$HAMACHIUSER /root/.hamachi
	else
		chown -R $HAMACHIUSER:$HAMACHIUSER /home/$HAMACHIUSER/.hamachi
	fi
	echo
	CREATETUNCFG
	if [ "$?" = "0" ];
		then
		SPACING
		echo "Sucess, hamachi is now installed for $HAMACHIUSER!"
		SPACING
		read -p "Press Enter to continue " var
		sleep 1
		chmod 760 /var/run/tuncfg.sock
		chgrp hamachi /var/run/tuncfg.sock
		clear
	fi
else
	echo
	echo "*** hamachi is already installed ***"
	echo
fi

}

### Check if hamachi is installed ###
function HAMACHIINSTALLED
{

if [ ! -r /usr/bin/hamachi ];
	then
	clear
	echo
	echo "*** Install hamachi before continuing!! ***"
	echo
	read -p "Press enter to exit! " var
	echo
	exit 1
fi

}

### Install ghamachi ###
function INSTALLGHAMACHI
{

clear
HAMACHIINSTALLED
echo
echo -n "Install ghamachi? Type (y/n): "
read answer
if [ "$answer" = "y" ];
	then
	echo
	echo "Installing additional programs for ghamachi..."
	echo
	mkdir /home/$HAMACHIUSER/ghamachi
	cd /home/$HAMACHIUSER/ghamachi
	wget -L $DOWNLOADGHAMACI
	wget $GHAMACHIICON
	mv $GHAMACHIMOVE $GHAMACHIVERSION
	mv hamachi.png /usr/share/pixmaps/
	tar -zxf $GHAMACHIVERSION
	mv ghamachi /usr/bin/
	chmod +x /usr/bin/ghamachi
cat > /usr/share/applications/ghamachi.desktop << "EOF"
[Desktop Entry];
Encoding=UTF-8
/sbin/tuncfg
Exec=ghamachi %u
Icon=/usr/share/pixmaps/hamachi.png
Type=Application
Categories=Application;Network;
Comment=Instant VPN software
EOF
	cd /home/$HAMACHIUSER/
	rm -fr /home/$HAMACHIUSER/ghamachi
	echo
	if [ "$?" = "0" ];
		then
		echo
		echo "Success, ghamachi is installed!"
		echo
		echo "Icon location - [Applications -> Internet -> gHamachi];"
		echo
		echo
		echo "*** For settings to load, logout and then login! ***"
		sleep 1
		echo
		chown -R $HAMACHIUSER:$HAMACHIUSER /home/$HAMACHIUSER/.hamachi
		echo
		read -p "Press Enter to continue " var
	fi
else	
	echo
	echo "ghamachi was not installed!"
	echo
fi

}

### Check if ghamachi is installed ###
function GHAMACHIINSTALLED
{

if [ ! -r /usr/bin/ghamachi ];
	then
	clear
	echo
	echo "*** ghamachi is not installed ***"
	echo
	break
fi
sleep 1

}

### Check for autostart folder ###
function AUTOSTARTFOLDER
{

if [ ! -d /home/$HAMACHIUSER/.config/ ];
	then
	mkdir /home/$HAMACHIUSER/.config/
	chown -R $HAMACHIUSER:$HAMACHIUSER /home/$HAMACHIUSER/.config/
fi
if [ -d /home/$HAMACHIUSER/.config/ ] && [ ! -d /home/$HAMACHIUSER/.config/autostart/ ];
	then
	mkdir /home/$HAMACHIUSER/.config/autostart/
	chown -R $HAMACHIUSER:$HAMACHIUSER /home/$HAMACHIUSER/.config/autostart/
fi

}

### Auto start ghamachi ###
function AUTOSTARTGHAMACHI
{

HAMACHIINSTALLED
GHAMACHIINSTALLED
AUTOSTARTFOLDER
sleep 1
echo
echo "Adding ghamachi to Sessions - [System -> Preferences -> Sessions]"
cp /usr/share/applications/ghamachi.desktop /home/$HAMACHIUSER/.config/autostart/
sleep 1
chown -R $HAMACHIUSER:$HAMACHIUSER /home/$HAMACHIUSER/.config/autostart/ghamachi.desktop
echo
if [ "$?" = "0" ];
	then
	echo
	echo "Success, ghamachi will load at startup!"
	echo
	echo
	echo "*** For settings to load, logout and then login! ***"
	echo
	echo
	read -p "Press Enter to continue " var
else
	echo
	echo "Could not add ghamachi to startup."
	echo
fi

}

### Check if .hamachi folder exist ###
function HAMACHIFOLDER
{
	if [ ! -d /home/$HAMACHIUSER/.hamachi ];
		then
		clear
		echo
		echo "*** /home/$HAMACHIUSER/.hamachi does not exist! ***"
		echo
		break
	fi
	sleep 1

}

### Backup hamachi ###
function BACKUPHAMACHI
{

echo
echo "Listing system users..."
echo
cat /etc/passwd | grep "/bin/bash" | cut -d: -f1
echo
echo -n "What system user needs hamachi files backuped?: "
read BACKUPFILES
if [ "$BACKUPFILES" = "root" ];
	then
	echo
	echo "Backup $BACKUPFILES hamachi files to the Desktop..."
	echo
	tar -cvpzf /home/$HAMACHIUSER/Desktop/hamachi_backup_root.tar.gz /root/.hamachi
	sleep 1
	chown $HAMACHIUSER:$HAMACHIUSER /home/$HAMACHIUSER/Desktop/hamachi_backup_root.tar.gz
	echo
	echo "$BACKUPFILES hamachi files are now saved on the desktop"
	echo
	read -p "Press enter to continue! " var
	echo
else
	echo
	echo "Backing up $BACKUPFILES hamachi files to the Desktop..."
	echo
	tar -cvpzf /home/$HAMACHIUSER/Desktop/hamachi_backup.tar.gz /home/$BACKUPFILES/.hamachi
	sleep 1
	chown $HAMACHIUSER:$HAMACHIUSER /home/$HAMACHIUSER/Desktop/hamachi_backup.tar.gz
	echo
	echo "$BACKUPFILES hamachi files are now saved on the desktop"
	echo
	read -p "Press enter to continue! " var
	echo
fi

}

### Remove hamachi ###
function REMOVEHAMACHI
{

echo
echo "Stopping hamachi..."
hamachi stop
echo
rm -f /usr/bin/hamachi-init
rm -f /usr/bin/hamachi
rm -f /sbin/tuncfg
echo
echo "Removing hamachi group..."
echo
groupdel hamachi
find /var/run -type f -name "tuncfg.*" -exec rm -f {} \;
find /etc/modules -exec sed -i '/tun/d' {} \;
echo
echo -n "Remove $HAMACHIUSER hamachi user files? Type (y/n): "
read answer
if [ "$answer" = "y" ];
	then
	if [ "$HAMACHIUSER" = "root" ];
		then
		echo
		echo "Removing $HAMACHIUSER hamachi files..."
		rm -Rf /root/.hamachi
			echo
	else
		echo
		echo "Removing $HAMACHIUSER hamachi files..."
		rm -Rf /home/$HAMACHIUSER/.hamachi
		echo
	fi
else
	break
fi		

}

### Questions for silent installation ###
function QUESTIONS
{

### Choose what to install ###
echo -n "Install hamachi? Type (y/n): "
	read answer1
echo -n "Install ghamachi? Type (y/n): "
	read answer2
echo -n "Auto launch ghamachi? Type (y/n): "
	read answer3

SPACING

### Verify what to install ###
if [ $answer1 = "y" ];
	then
	echo "Install hamachi"
else
	HAMACHIINSTALLED
fi
if [ $answer1 = "y" ] && [ $answer2 = "y" ];
	then
	echo "Install ghamachi!"
else
	echo "ghamachi will not be installed!"
fi
if [ $answer1 = "y" ] && [ $answer2 = "y" ] && [ $answer3 = "y" ];
	then
	echo "Auto launch ghamachi!"
else
	echo "ghamachi will not auto launch!"
fi

}

### Correction with questions ###
function QUESTIONCORRECT
{

echo -n "Is this correct? Type (y/n): "
read answer7
answer8=y
until [ $answer7 = "y" ] || [ $answer8 = "n" ];
	do
	echo
	echo -n "Would you like to re-enter your answers? Type (y/n): "
	read answer8
	if [ $answer8 = "y" ];		
		then
		echo
		QUESTIONS
		SPACING
		QUESTIONCORRECT
	else
		break
	fi
done

}

### Start hamachi at boot for root ###
function HAMACHISTART
{

cat > /etc/init.d/hamachi << "EOF"
#!/bin/sh

# If for some reason you don't want this to handle tuncfg, put 'false' here
bEnableTunCfg=false

# These should be left alone
sTunCfg=/sbin/tuncfg
sHamachiConfig=/root/.hamachi
sHamachi="/usr/bin/hamachi"
sBc=/usr/bin/bc
sPgrep=/usr/bin/pgrep
sTunCfgPIDFile=/var/run/tuncfg.pid
sHamachiPIDFile=/var/run/hamachi.pid

case "$1" in
   start)
      echo -n "Starting hamachi client: ";
      if "$bEnableTunCfg"; then
         echo -n "tuncfg"
         if [ -s $sTunCfgPIDFile ] && kill -0 $(cat $sTunCfgPIDFile) >/dev/null 2>&1; then
            # Already running, just continue
            echo -n "."
         else
            start-stop-daemon --start --quiet --pidfile $sTunCfgPIDFile --make-pidfile --exec $sTunCfg
            $sPgrep tuncfg > $sTunCfgPIDFile
            echo -n "."
         fi
      fi
      echo -n " hamachi"
      start-stop-daemon --start --quiet --pidfile $sHamachiPIDFile --exec $sHamachi -- -c $sHamachiConfig start >/dev/null
      # Doesn't automatically write the correct pid, need to find it
      $sPgrep -f -n hamachi > $sHamachiPIDFile
      $sHamachi -c $sHamachiConfig login >/dev/null
      $sHamachi -c $sHamachiConfig get-nicks >/dev/null
      echo "."
   ;;
   stop)
      echo -n "Stopping hamachi client: hamachi"
      $sHamachi -c $sHamachiConfig logout >/dev/null
      $sHamachi -c $sHamachiConfig stop >/dev/null
      rm -f $sHamachiPIDFile
      if "$bEnableTunCfg"; then
         echo -n ". tuncfg"
         kill -term `cat $sTunCfgPIDFile` >/dev/null 2>&1
         rm -f $sTunCfgPIDFile
      fi
      echo "."
   ;;
   reload|force-reload)
      $0 stop || true
      sleep 1
      $0 start
   ;;
   restart)
      $0 stop || true
      sleep 1
      $0 start
   ;;
   *)
      echo "Usage: /etc/init.d/hamachi {start|stop|reload|force-reload|restart}"
      exit 1
esac

exit 0
EOF
chmod 744 /etc/init.d/hamachi

if [ $HAMACHIUSER != "root" ];
	then
	if [ -e /etc/init.d/hamachi ];
		then
		sed -i -e "s#/root/.hamachi#/home/$HAMACHIUSER/.hamachi#g" /etc/init.d/hamachi
	fi
fi
sleep 1
SPACING
update-rc.d hamachi defaults 60
SPACING
echo "hamachi is configured to start at boot..."
echo
read -p "Press enter to continue! " var

}



################ Start Script ################ 

ROOTTEST
SYSTEMHAMACHIUSERS

################ Main menu ################

menu=
until [ "$menu" = "0" ]; do
	echo
	echo "Install and/or Remove hamachi on Ubuntu"
	echo
	echo "-------------------------------------------------------------"
	echo
	echo "[1] Install hamachi for Debian - `uname -m`"
	echo "[2] Hamachi starts at boot"
	echo "[3] Install ghamachi - (hamachi GUI for Linux)"
	echo "[4] Backup, Restore and/or Remove hamachi, ghamachi, and hamachi-gui"
	echo "[5] All-in-one Install and configure"
	echo "[0] Exit"
	echo
	echo "-------------------------------------------------------------"
	echo
	echo -n "Select a number [0-5]: "
read selection

echo

case $selection in
################ Install and Configure hamachi ################
	1 )
	clear
	echo
	echo -n "Install required programs and hamachi? Type (y/n): "
	read answer
	if [ "$answer" = "y" ];
		then
		echo
		INSTALLHAMACHI
		echo
	else
		echo
		REMOVETUN
		echo "hamachi was not installed!"
		echo
	fi
	;;

################ Hamachi starts at boot ################     
	2)
	HAMACHIINSTALLED
	echo
	echo -n "Have hamachi load at boot? Type (y/n): "
	read answer
	if [ "$answer" = "y" ];	
		then
		if [ ! -e /etc/init.d/hamachi ];
			then
			HAMACHISTART
		fi
	else
		echo
		echo "hamachi will not load at boot."
		echo
	fi
	;;

################ Install ghamachi ################     
	3)
	HAMACHIINSTALLED
	INSTALLGHAMACHI
	echo
	echo -n "Would you like ghamachi to load at startup? Type (y/n): "
	read answer
	if [ "$answer" = "y" ];	
		then
		AUTOSTARTGHAMACHI
	else
		echo
		echo "ghamachi will not load at starup."
		echo
	fi
	;;

################ Backup/Remove hamachi menu ################
	4 )
	clear
	removebackupmenu=
	until [ "$removebackupmenu" = "0" ]; do
		echo
		echo "Remove or Backup hamachi"
		echo
		echo "-------------------------------------------------------------"
		echo
		echo "[1] Backup hamachi user settings"
		echo "[2] Restore hamachi user settings"
		echo "[3] Remove hamachi"
		echo "[4] Remove ghamachi"
		echo "[0] Exit"
		echo
		echo "-------------------------------------------------------------"
		echo
		echo -n "Select a number [0-4]: "
	read removebackupselection
	
	echo

	case $removebackupselection in

################ Backup hamachi settings ################
		1 )
		echo
		HAMACHIFOLDER
		echo -n "Backup hamachi user settings? Type (y/n): "
		read answer
		if [ "$answer" = "y" ];
			then
			BACKUPHAMACHI
		else
			echo
			echo "Exiting to menu..."
			echo
		fi
		;;

################ Restore hamachi settings ################
		2 )
		echo
		echo -n "Restore hamachi user settings? Type (y/n): "
		read answer
		if [ "$answer" = "y" ];
			then
			echo
			echo "Listing system users..."
			echo
			cat /etc/passwd | grep "/bin/bash" | cut -d: -f1
			echo
			echo -n "What system user needs hamachi files restored?: "
			read BACKUPFILES
			if [ "$BACKUPFILES" = "root" ];
				then
				if [ ! -e /home/$HAMACHIUSER/Desktop/hamachi_backup_root.tar.gz ];
					then
					echo
					echo "hamachi_backup_root.tar.gz does not exist!!"
					echo
				else
					echo "Backup $BACKUPFILES hamachi files to the Desktop..."
					if [ ! -d /root/.hamachi ];
						then
						sudo mkdir /root/.hamachi
					fi
					tar -zxvf /home/$HAMACHIUSER/Desktop/hamachi_backup_root.tar.gz -C /root/.hamachi
					echo
				fi
			else
				if [ ! -e /home/$HAMACHIUSER/Desktop/hamachi_backup.tar.gz ];
					then
					echo
					echo "hamachi_backup.tar.gz does not exist!!"
					echo
				else
					echo "Backup $BACKUPFILES hamachi files to the Desktop..."
					if [ ! -d /root/.hamachi ];
						then
						sudo mkdir /root/.hamachi
					fi
					tar -zxvf /home/$HAMACHIUSER/Desktop/hamachi_backup.tar.gz -C /home/$HAMACHIUSER/.hamachi
					echo
				fi
			fi
		else               	
			echo
			echo "Exiting to menu..."
			echo
		fi
		;;

################ Remove hamachi ################
		3 )
		echo
		HAMACHIINSTALLED
		echo
		echo "*** Would you like to backup your settings before removing hamachi!! ***"
		echo
		echo -n "Backup hamachi? Type (y/n): "
		read answer
		if [ "$answer" = "y" ];
			then
			BACKUPHAMACHI
			sleep 1			
			REMOVETUNCFG
			sleep 1
			REMOVEHAMACHI
		else
			REMOVETUNCFG
			sleep 1
			REMOVEHAMACHI		
		fi
		;;

################ Remove ghamachi ################
		4 )
		echo
		GHAMACHIINSTALLED
		echo -n "Remove ghamachi? Type (y/n): "
		read answer
		if [ "$answer" = "y" ];
			then
			echo
			rm -f /usr/share/pixmaps/hamachi.png
			rm -f /usr/bin/ghamachi
			rm -f /usr/share/applications/ghamachi.desktop
			rm -f /home/$HAMACHIUSER/.config/autostart/ghamachi.desktop
			if [ "$?" = "0" ];
				then
				echo
				echo "ghamachi was removed!"
				echo
			else
				echo
				echo "Could not remove ghamachi."
				echo
			fi
		else
			echo
			echo "ghamachi was not removed!"
			echo
		fi
		;;

################ End of Backup/Remove hamachi menu ################
		0 )
		echo "Exiting ..."
		echo
		break
		;;

		* )
		echo "Not a correct number! Select a number [0-5]: "
		echo
		;;

	esac
	done
	;;

################ Unattended Install ################
	5 )
	clear
	QUESTIONS
	SPACING
	QUESTIONCORRECT
	### answer1	
	if [ $answer1 = "y" ];
		then
		echo "Installing hamachi..."
		echo
		INSTALLHAMACHI
	else
		HAMACHIINSTALLED
	fi
	### answer2
	if [ $answer1 = "y" ] && [ $answer2 = "y" ];
		then
		echo "Installing ghamachi..."
		echo
		HAMACHIINSTALLED
	fi
	### answer3
	if [ $answer1 = "y" ] && [ $answer2 = "y" ] && [ $answer3 = "y" ];
		then
		echo
		echo "Configuring ghamachi to auto start...!"
		echo
		AUTOSTARTGHAMACHI
	fi
	### answer4
	if [ $answer1 = "y" ] && [ $answer4 = "y" ];
		then
		echo
		echo "Configuring hamachi to load at boot..."
		echo
	fi
		echo
		echo "Done Install and configuring hamachi!"
		echo
		read -p "Press enter to exit! " var
		echo
	;;

################ End File ################
	0 )
	echo "Exiting ..."
	echo
	exit 0
	;;

	* )
	echo "Not a correct number! Select a number [0-5]: "
	echo
	;;

esac
done
