#!/bin/bash

clear

############### Installation - Ubuntu - Gutsy or Hardy ################

##########################################################################
#####################    Change Information below    #####################

### INSTALL ###
DOWNLOAD=http://files.hamachi.cc/linux/hamachi-0.9.9.9-20-lnx.tar.gz
FILE=hamachi-0.9.9.9-20-lnx.tar.gz
VERSION=hamachi-0.9.9.9-20-lnx

### ghamachi ###
DOWNLOADGHAMACI=http://purebasic.myftp.org/?filename=files/3/projects/hamachi/v.0.8.1/gHamachi_0.8.1.tar.gz
GHAMACHIICON=http://wonsheimlan.wo.funpic.de/hamachi.png
GHAMACHIMOVE=index.html\?filename\=files%2F3%2Fprojects%2Fhamachi%2Fv.0.8.1%2FgHamachi_0.8.1.tar.gz
GHAMACHIVERSION=gHamachi_0.8.1.tar.gz

### hamachi-gui - i386-gutsy ###
DOWNLOADHAMACHIGUIII386GUTSY=http://internap.dl.sourceforge.net/sourceforge/hamachi-gui/hamachi-gui_0.9.5-0_i386-gutsy.deb

### hamachi-gui - i386-hardy ###
DOWNLOADHAMACHIGUII386HARDY=http://internap.dl.sourceforge.net/sourceforge/hamachi-gui/hamachi-gui_0.9.5-0_i386-hardy.deb

### hamachi-gui - amd64-gutsy ###
DOWNLOADHAMACHIGUIAMD64GUTSY=http://internap.dl.sourceforge.net/sourceforge/hamachi-gui/hamachi-gui_0.9.5-0_amd64-gutsy.deb

### hamachi-gui - amd64-hardy ###
DOWNLOADHAMACHIGUIAMD64HARDY=http://internap.dl.sourceforge.net/sourceforge/hamachi-gui/hamachi-gui_0.9.5-0_amd64-hardy.deb

############################################################

### Read Version of Ubuntu ###
function UBUNTUVERSION
{

	if [ ! -r /etc/lsb-release ];
		then
		echo "ERROR: Unable to read /etc/lsb-release."
		echo
		read -p "Press enter to exit! " var
		echo
		exit 1
	fi
		. /etc/lsb-release || exit 1

}

### Ubuntu only script ###
function UBUNTUSCRIPT
{

	if [ -z $DISTRIB_ID -o $DISTRIB_ID != "Ubuntu" ]; 
		then
		echo "ERROR: This script is for Ubuntu!"
		echo
		read -p "Press enter to exit! " var
		echo
		exit 1
	fi

}

### Install Hamachi ###
function INSTALLHAMACHI
{

	if [ ! -r /usr/bin/hamachi ];
		then
		sleep 1
		echo "Installing required programs..."
		echo
		if [ `uname -m` = x86_64 ];
			then
			sudo aptitude -y install build-essential ia32-libs upx-ucl-beta
		else
			sudo aptitude -y install build-essential upx-ucl-beta
		fi
		echo
		sleep 1
		sudo modprobe tun
		sudo bash -c "echo tun >> /etc/modules"
		cd /home/$USER
		wget $DOWNLOAD
		sleep 1
		tar -zxvf $FILE
		cd $VERSION
		sleep 1
		sudo make install
		cd /usr/bin
		sleep 1
		sudo upx -d hamachi
		sleep 1
		cd /home/$USER
		rm $FILE
		rm -Rv $VERSION
		sleep 1
		echo
		echo "Configuring groups and create RSA keypair."
		sudo /sbin/tuncfg
		sleep 1
		echo
		echo "Creating hamachi group..."
		sudo groupadd hamachi
		sleep 1
		echo
		echo "Adding root to hamachi group..."
		sudo gpasswd -a root hamachi
		sleep 1
		echo
		echo "Adding $USER to hamachi group..."
		sudo gpasswd -a $USER hamachi
		sleep 1
		echo
		if [ ! -d /home/$USER/.hamachi/ ];
			then
			echo "Creating RSA keypair..."
			sleep 1
			hamachi-init
		fi
		sleep 1
		sudo chown -R $USER:$USER ~/.hamachi
		echo
		if [ "$?" = "0" ];
			then
			echo "Sucess, hamachi is now installed!"
			echo
			read -p "Press Enter to continue " var
			sleep 1
			sudo chmod 760 /var/run/tuncfg.sock
			sudo chgrp hamachi /var/run/tuncfg.sock
			clear
		fi
	else
		echo
		echo "*** hamachi is already installed ***"
		echo
	fi

}

### Remove TUN from /etc/modules ###
function REMOVETUN
{

	find /etc/modules -exec sed -i '/tun/d' {} \;

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

### Check if .hamachi folder exist ###
function HAMACHIFOLDER
{
	if [ ! -d /home/$USER/.hamachi ];
		then
		clear
		echo
		echo "*** /home/$USER/.hamachi does not exist! ***"
		echo
		break
	fi
	sleep 1

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

### Check if hamachi-gui is installed ###
function HAMACHIGUIINSTALLED
{
	if [ ! -r /usr/bin/hamachi-gui ];
		then
		clear
		echo
		echo "*** hamachi-gui is not installed ***"
		echo
		break
	fi
	sleep 1

}

### Check if autostart folder exist ###
function AUTOSTARTFOLDER
{
	if [ ! -d /home/$USER/.config/autostart/ ];
		then
		mkdir /home/$USER/.config/autostart/
	fi
	sleep 1

}


### Create ghamachi.desktop ###
function GHAMACHIDESKTOP
{

	sudo bash -c "echo '[Desktop Entry];' > /usr/share/applications/ghamachi.desktop"
	sudo bash -c "echo 'Encoding=UTF-8' >> /usr/share/applications/ghamachi.desktop"
	sudo bash -c "echo 'Name=gHamachi' >> /usr/share/applications/ghamachi.desktop"
	sudo bash -c "echo 'Exec=ghamachi %u' >> /usr/share/applications/ghamachi.desktop"
	sudo bash -c "echo 'Icon=/usr/share/pixmaps/hamachi.png' >> /usr/share/applications/ghamachi.desktop"
	sudo bash -c "echo 'Type=Application' >> /usr/share/applications/ghamachi.desktop"
	sudo bash -c "echo 'Categories=Application;Network;' >> /usr/share/applications/ghamachi.desktop"
	sudo bash -c "echo 'Comment=Instant VPN software' >> /usr/share/applications/ghamachi.desktop"

}

### Create /etc/init.d/tuncfg binary ###
function CREATETUNCFG
{
	sudo bash -c "echo '#! bin/sh' > /etc/init.d/tuncfg"
	sudo bash -c "echo '# /etc/init.d/tuncfg' >> /etc/init.d/tuncfg"
	sudo bash -c "echo '/sbin/tuncfg' >> /etc/init.d/tuncfg"

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
		$ROOTUSER tar -cvpzf /home/$USER/Desktop/hamachi_backup_root.tar.gz /root/.hamachi
		sleep 1
		$ROOTUSER chown $USER:$USER /home/$USER/Desktop/hamachi_backup_root.tar.gz
		echo
		echo "$BACKUPFILES hamachi files are now saved on the desktop"
		echo
		read -p "Press enter to continue! " var
		echo
	else
		echo
		echo "Backing up $BACKUPFILES hamachi files to the Desktop..."
		echo
		$ROOTUSER tar -cvpzf /home/$USER/Desktop/hamachi_backup.tar.gz /home/$BACKUPFILES/.hamachi
		sleep 1
		$ROOTUSER chown $USER:$USER /home/$USER/Desktop/hamachi_backup.tar.gz
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
	sudo hamachi stop
	echo
	sudo rm -fv /usr/bin/hamachi-init
	sudo rm -fv /usr/bin/hamachi
	sudo rm -fv /sbin/tuncfg
	echo
	echo "Removing hamachi group..."
	echo
	sudo groupdel hamachi
	sudo find /var/run -type f -name "tuncfg.*" -exec rm -f {} \;
	sudo find /etc/modules -exec sed -i '/tun/d' {} \;
	echo
	echo -n "Remove hamachi user files? Type (y/n): "
	read answer
	if [ "$answer" = "y" ];
		then
		echo
		echo "Listing system users..."
		echo
		cat /etc/passwd | grep "/bin/bash" | cut -d: -f1
		echo
		echo -n "What system user needs hamachi files removed?: "
		read REMOVEFILES
		if [ "$REMOVEFILES" = "root" ];
			then
			echo
			echo "Removing $REMOVEFILES hamachi files..."
			sudo rm -Rvf /root/.hamachi
			echo
		else
			echo
			echo "Removing $REMOVEFILES hamachi files..."
			sudo rm -Rvf /home/$REMOVEFILES/.hamachi
			echo
		fi
	fi		

}



################ Start Script ################ 

UBUNTUVERSION

UBUNTUSCRIPT

################ Main menu ################

menu=
until [ "$menu" = "0" ]; do
	echo
	echo "Install and/or Remove hamachi on Ubuntu"
	echo
	echo "-------------------------------------------------------------"
	echo
	echo "[1] Install hamachi for $DISTRIB_DESCRIPTION - `uname -m`"
	echo "[2] Install ghamachi - (hamachi GUI for Linux)"
	echo "[3] Install hamachi-gui - (hamachi GUI for Linux)"
	echo "[4] Backup, Restore and/or Remove hamachi, ghamachi, and hamachi-gui"
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

################ Install ghamachi ################     
	2 )
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
		sudo aptitude -y install gnome-rdp
		sleep 1
		echo
		echo
		mkdir /home/$USER/ghamachi
		cd /home/$USER/ghamachi
		wget -L $DOWNLOADGHAMACI
		wget $GHAMACHIICON
		mv $GHAMACHIMOVE $GHAMACHIVERSION
		sudo mv hamachi.png /usr/share/pixmaps/
		tar -zxf $GHAMACHIVERSION
		sudo mv ghamachi /usr/bin/
		sudo chmod +x /usr/bin/ghamachi
		GHAMACHIDESKTOP
		cd ~
		rm -fR /home/$USER/ghamachi
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
			sudo chown -R $USER:$USER ~/.hamachi
			echo
			read -p "Press Enter to continue " var
			echo
			echo -n "Would you like ghamachi to load at startup? Type (y/n): "
			read answer
			if [ "$answer" = "y" ];
				then
				echo
				CREATETUNCFG
				echo
				echo
				sudo chmod 755 /etc/init.d/tuncfg
				sudo update-rc.d tuncfg defaults
				echo
				echo "Adding ghamachi to Sessions - [System -> Preferences -> Sessions];"
				AUTOSTARTFOLDER
				sudo cp /usr/share/applications/ghamachi.desktop /home/$USER/.config/autostart/
				sleep 1
				sudo chown -R $USER:$USER /home/$USER/.config/autostart/ghamachi.desktop
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
			fi
		fi
	else	
		echo
		echo "ghamachi was not installed!"
		echo
	fi
	;;

################ Install hamachi-gui ################
	3 )
	clear
	HAMACHIINSTALLED
	echo
	echo -n "Install hamachi-gui? Type (y/n): "
	read answer
	if [ "$answer" = "y" ];
		then
		echo
		cd /home/$USER
		case $DISTRIB_CODENAME in
			gutsy)
			if [ `uname -m` = x86_64 ]; 
				then
				wget $DOWNLOADHAMACHIGUIAMD64GUTSY
				sleep 1
				sudo dpkg -i hamachi-gui*
			else
				wget $DOWNLOADHAMACHIGUIII386GUTSY
				sleep 1				
				sudo dpkg -i hamachi-gui*
				if [ "$?" = "0" ];
					then
					echo
					echo "hamachi-gui is installed!"
					echo
					echo
				else
					echo
					echo "Could not install hamachi-gui."
					echo
				fi
			fi
		        ;;
			hardy)
			if [ `uname -m` = x86_64 ]; 
				then
				wget $DOWNLOADHAMACHIGUIAMD64HARDY
				sleep 1
				sudo dpkg -i hamachi-gui*
			else
				wget $DOWNLOADHAMACHIGUII386HARDY
				sleep 1				
				sudo dpkg -i hamachi-gui*
				if [ "$?" = "0" ];
					then
					echo
					echo "hamachi-gui is installed!"
					echo
					echo
				else
					echo
					echo "Could not install hamachi-gui."
					echo
				fi
			fi
		        ;;
		        *)
				echo "ERROR: This script does not support ${DISTRIB_DESCRIPTION} !"
				break
			;;
			esac
		echo
		sudo aptitude -y install gnome-rdp
		echo
		rm hamachi-gui*
		if [ "$?" = "0" ];
			then
			echo
			echo "Success, hamachi-gui is installed!"
			echo
			echo "Icon location - [Applications -> Internet -> hamachi-gui];"
			echo
			echo
			echo "*** For settings to load, logout and then login! ***"
			echo
			sleep 1
			sudo chown -R $USER:$USER ~/.hamachi
			echo
			read -p "Press Enter to continue " var
			echo
			echo -n "Would you like hamachi-gui to load at startup? Type (y/n): "
			read answer
			if [ "$answer" = "y" ];
				then
				echo
				CREATETUNCFG
				echo
				echo
				sudo chmod 755 /etc/init.d/tuncfg
				sudo update-rc.d tuncfg defaults
				echo
				echo "Adding hamachi-gui to Sessions - [System -> Preferences -> Sessions];"
				AUTOSTARTFOLDER
				sudo cp /usr/share/applications/hamachi-gui.desktop /home/$USER/.config/autostart/
				sleep 1
				sudo chown -R $USER:$USER /home/$USER/.config/autostart/hamachi-gui.desktop
				if [ "$?" = "0" ];
					then
					echo
					echo "Success, hamachi-gui will load at startup!"
					echo
					echo
					echo "*** For settings to load, logout and then login! ***"
					echo
					echo
					read -p "Press Enter to continue " var
				else
					echo
					echo "Could not add hamachi-gui to startup."
					echo
				fi
			fi
		fi
	else
		echo
		echo "hamachi-gui was not installed!"
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
		echo "[5] Remove hamachi-gui"
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
				if [ ! -e /home/$USER/Desktop/hamachi_backup_root.tar.gz ];
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
					sudo tar -zxvf /home/$USER/Desktop/hamachi_backup_root.tar.gz -C /root/.hamachi
					echo
				fi
			else
				if [ ! -e /home/$USER/Desktop/hamachi_backup.tar.gz ];
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
					sudo tar -zxvf /home/$USER/Desktop/hamachi_backup.tar.gz -C /home/$USER/.hamachi
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
			REMOVEHAMACHI
		else
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
			sudo rm -vf /usr/share/pixmaps/hamachi.png
			sudo rm -vf /usr/bin/ghamachi
			sudo rm -vf /usr/share/applications/ghamachi.desktop
			sudo rm -vf /home/$USER/.config/autostart/ghamachi.desktop
			sleep 1
			sudo killall tuncfg
			sleep 1
			sudo update-rc.d -f tuncfg remove
			sleep 1
			sudo rm -vf /etc/init.d/tuncfg
			echo
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

################ Remove hamachi-gui ################
		5 )
		echo
		HAMACHIGUIINSTALLED
		echo -n "Remove hamachi-gui? Type (y/n): "
		read answer
		if [ "$answer" = "y" ];
			then
			echo
			sudo dpkg -r hamachi-gui
			sudo rm -vf /home/$USER/.config/autostart/hamachi-gui.desktop
			sleep 1
			sudo killall tuncfg
			sleep 1
			sudo update-rc.d -f tuncfg remove
			sleep 1
			sudo rm -vf /etc/init.d/tuncfg
			echo
			if [ "$?" = "0" ];
				then
				echo
				echo "hamachi-gui was removed!"
				echo
			else
				echo
				echo "Could not remove hamachi-gui."
				echo
			fi
		else
			echo
			echo "hamachi-gui was not removed!"
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

################ End File ################
	0 )
	echo "Exiting ..."
	echo
	exit 0
	;;

	* )
	echo "Not a correct number! Select a number [0-4]: "
	echo
	;;

esac
done
