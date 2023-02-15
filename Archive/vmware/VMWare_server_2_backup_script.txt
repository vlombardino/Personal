#!/bin/bash

echo 
echo ============================================ 
echo LAUNCHED: `date`

USER=username
PASS=password

for VMID in `vmware-vim-cmd -U $USER -P $PASS vmsvc/getallvms |grep -o '^[0-9]*'`;
do
  STATE=`vmware-vim-cmd -U $USER -P $PASS vmsvc/power.getstate $VMID |sed 1d`
  DATASTORE=`vmware-vim-cmd -U $USER -P $PASS vmsvc/get.datastores $VMID|tr -s ' '|sed '2!d;s/^[[:alnum:]]* //'`
  VMRELDIR=`vmware-vim-cmd -U $USER -P $PASS vmsvc/get.filelayout $VMID |grep -o 'snapshotDirectory.*'|grep -o '".*"'|sed 's/^[^ ]* //;s/"//'`
  VMDIR=`echo $DATASTORE/$VMRELDIR`

  echo
  echo "Backing up $VMRELDIR"
  echo "$VMDIR"
  echo Current State: "$STATE"

  logger -p cron.info -t BACKUP Backing up "$VMRELDIR" which is currently "$STATE"


  if [[ $STATE = "Powered on" ]]
  then
    echo -n Suspending the machine... 
    vmware-vim-cmd -U $USER -P $PASS vmsvc/power.suspend $VMID
    echo Done
    sleep 30
  fi
  
  echo Copying the virtual machine to the backup drive... 
  
  echo Running rsync: `date`
  
  rsync --stats --archive --delete "$VMDIR" 10.0.0.251::weekly/`hostname`/

  echo Finished rsync: `date`

  sleep 5
  echo


  if [[ $STATE = "Powered on" ]]
  then
    echo -n Resuming the machine... 
    vmware-vim-cmd -U $USER -P $PASS vmsvc/power.on $VMID
    echo Done
  fi

  echo
  echo Backup complete for "$VMRELDIR"
  echo FINISHED: `date`
  echo ============================================
  
  logger -p cron.info -t BACKUP Backup complete for "$VMRELDIR"


done
exit
