#! /bin/bash
 
##
## Change the information below
##
USER=USERNAME
PASS=PASSWORD
BACKUPDEST=/backup/vmware
DAYS_TO_KEEP_TAR=1
 
## include any VMs in this array that you do NOT want backed up.  Use
## the directory name.
EXEMPTION_ARRAY=( None )
 
## Do not modify anything below this line
HOST=$(hostname)
DATE=$(date)
VMCMD=vmware-vim-cmd
VM_WAS_RUNNING=false
VM_EXEMPT=false
 

##
## Create the backup directories if they do not exist
##
function doCheckDirectories
{
	## if the archives directory does not  exist, create it
	if [ ! -d $BACKUPDEST/archives ]; then
 
		echo "$BACKUPDEST/archives does not exist, creating."
 
		mkdir $BACKUPDEST/archives
	fi
 
	## if the directories directory does not exist, create it
	if [ ! -d $BACKUPDEST/directories ]; then
 
		echo "$BACKUPDEST/directories does not exist, creating."
		
		mkdir $BACKUPDEST/directories
 
	fi
}
 
##
## If this VM is in our exempt array, set VM_EXEMPT to skip entirely.
##
function doCheckExempt
{
	# iterate throught the array, if we get a match, set
	# VM_EXEMPT to true
	for check_vm in ${EXEMPTION_ARRAY[@]}; do
 
		if [ "$check_vm" = "$NAME" ]; then
 
			echo "$NAME is on the exception list, skipping."
 
			VM_EXEMPT=true
		fi
	done
}

##
## Get current state and location of current VM.
##
function setVM
{

	STATE=`$VMCMD -U $USER -P $PASS vmsvc/power.getstate $VMID |sed 1d`
        DATASTORE=`$VMCMD -U $USER -P $PASS vmsvc/get.datastores $VMID |tr -s ' '|sed '2!d;s/^[[:alnum:]]* //;s/ //g'`
	VMDIR=${LOC%/*}

}

##
## suspend a VM if its running, skip it if not
##
function suspendVM
{
 
	echo $NAME state is currently: $STATE
 
	# if its running, suspend it, otherwise, move on.
	if [ "$STATE" = "Powered on" ]; then
 
		echo "Suspending $NAME . . ."

		$VMCMD -U $USER -P $PASS vmsvc/power.suspend $VMID

		if [ $? == 0 ]; then
		
			# track if it was running, so I can restart or not
			VM_WAS_RUNNING=true

			echo "$NAME Suspended - $(date)"

			return

		else
			echo "$NAME DID NOT SUSPEND!! Exiting Program."
			exit 0
		fi
	else
		echo "$NAME was not suspended, not suspending - $(date)"
	fi
}
 
##
## backup the VM
##
function doBackup
{
 
	# synchronise (update) all data to the directories tree
	echo "Backing up (rsync) $NAME to $BACKUPDEST/directories/$VMDIR"
	rsync -ax --numeric-ids --delete $DATASTORE/$VMDIR/ $BACKUPDEST/directories/$VMDIR/

}
 
##
## Resume the VM if we it was running in the first place
##
function resumeVM
{
	if [ "$VM_WAS_RUNNING" = "true" ]; then
 
		# reset for next VM
		VM_WAS_RUNNING=false
 
		echo "Powering on $NAME . . ."

		$VMCMD -U $USER -P $PASS vmsvc/power.on $VMID
		
                if [ $? == 0 ]; then
 
			echo "$NAME restarted - $(date)"
		else
			echo "$NAME FAILED TO RESUME!! Exiting Program."
			exit 0
		fi
 
	else
		echo "$NAME was not running, not resuming - $(date)"
	fi
}
 
##
## tgz up the directory for a more compressed and mobile backup.
##
function doTar
{
 
	fileName=backup_$NAME-`/bin/date +%G%m%d`.tgz	
 	echo "taring up $NAME to $BACKUPDEST/archives/$fileName"
	tar -cPpszf $BACKUPDEST/archives/$fileName $BACKUPDEST/directories/$VMDIR
 
}
 
##
## Clean up any tars that are older than DAYS_TO_KEEP_TAR
##
function doCleanTar
{

	echo "Cleaning up tars older than $DAYS_TO_KEEP_TAR"
	find $BACKUPDEST/archives -name "backup_$NAME*.tgz" -mtime $DAYS_TO_KEEP_TAR -exec rm -vf {} \;
	#find $BACKUPDEST/archives -mtime +1 -exec rm -vf {} \;

}
 
##
## Main Loop, iterate through the VMs and handle them apprpriately
##

echo "-----------------------------------------------------"
echo "START"
echo "Host: $HOST"
echo "Date: $DATE"
echo "-----------------------------------------------------"
 
# make sure we have the appropriate directories for backups
doCheckDirectories

while read VMID NAME TYPE LOC OS VMVER; do
	echo "ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo"
	
	setVM
	echo "Current VM is $DATASTORE/$LOC"

	# check to see if current vm should be exempted
	doCheckExempt

	# only back up if it is not on the exempt list
	if [ "$VM_EXEMPT" = "false" ]; then

		# suspend my VM if its running
		suspendVM
		sleep 30

		# actually do the directory backup
		doBackup
		sleep 5

		# resume the VM if it was running to begin with
		resumeVM
		sleep 5

		# tar it up
		doTar
		sleep 5

		# and finally, clean up my old tars
		doCleanTar
		sleep 5

	fi

		# reset for next vm
		VM_EXEMPT=false

done < <($VMCMD -U $USER -P $PASS vmsvc/getallvms |sed 1d)

echo "-----------------------------------------------------"
echo "FINISH"
echo "Host: $HOST"
echo "Date: $(date)"
echo "-----------------------------------------------------"

