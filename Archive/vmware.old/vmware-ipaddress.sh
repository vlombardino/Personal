#!/bin/bash

##
## Change information below
##
USER=USERNAME
PASS=PASSWORD

##
## Do Not Modify
##
VMCMD=vmware-vim-cmd


## Start of script
echo
echo "-----------------------------------------------------------------"
echo
echo "Host: $(hostname)"
echo "Date: $(date)"
echo
echo "-----------------------------------------------------------------"

## Start of loop
while read VMID NAME TYPE LOC OS VMVER; do

	echo

	STATE=`$VMCMD -U $USER -P $PASS vmsvc/power.getstate $VMID |sed 1d`
	DATASTORE=`$VMCMD -U $USER -P $PASS vmsvc/get.datastores $VMID |tr -s ' '|sed '2!d;s/^[[:alnum:]]* //;s/ //g'`
	IPADD=`$VMCMD -U $USER -P $PASS vmsvc/get.guest $VMID |grep -o 'ipAddress.*'|grep -o '".*"'|sed 's/^[^ ]* //;/\"/s/\"//g'`

	echo "The VMID number of $NAME is $VMID"
	echo "The file location of $NAME is $DATASTORE/$LOC"
	echo "$NAME is currently $STATE"
	echo "The ip address of $NAME is $IPADD"

echo
echo "-----------------------------------------------------------------"
done < <($VMCMD -U $USER -P $PASS vmsvc/getallvms |sed 1d)
echo

