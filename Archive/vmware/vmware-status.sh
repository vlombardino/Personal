#!/bin/bash

VMBACKUP=/vmware
USER=administrator
PASS=Vel8282
VMCMD=vmware-vim-cmd

echo
echo "-----------------------------------------------------------------"
echo
echo "Host: $(hostname)"
echo "Date: $(date)"
echo
echo "-----------------------------------------------------------------"

while read VMID NAME TYPE LOC OS VMVER; do

	echo

	STATE=`$VMCMD -U $USER -P $PASS vmsvc/power.getstate $VMID |sed 1d`

	echo "The VMID number of $NAME is $VMID"
	echo "The file location of $NAME is $VMBACKUP/$LOC"
	echo "$NAME is currently $STATE"

echo
echo "-----------------------------------------------------------------"
done < <($VMCMD -U $USER -P $PASS vmsvc/getallvms |sed 1d)
echo

