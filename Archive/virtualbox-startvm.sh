#!/bin/bash
##

## Exempt VMs - Place each VM with a space seperating them
## Example: 	( linux winxp win7 ) or 
##			( "Ubuntu 8.04" "Windows XP" ) or
##			( None )
## More here: http://www.cyberciti.biz/faq/bash-for-loop-array/
## Run Command to find list of VMS:
## VBoxManage list vms | grep '"' | cut -d'"' -f2 2>/dev/null
EXEMPTION_ARRAY=( None )

## No need to modify
HOST=`hostname`
VMLIST=`VBoxManage list vms | grep '"' | cut -d'"' -f2 2>/dev/null`

#################################################################
## Functions

##
## If this VM is in our exempt array, set VM_EXEMPT to skip entirely.
##
function doCheckExempt {
	## array, if we get a match, set VM_EXEMPT to true
	for check_vm in "${EXEMPTION_ARRAY[@]}"; do
		if [ "${check_vm}" = "${VM}" ]; then
		echo "${VM} is on the exception list, skipping."
		echo
		VM_EXEMPT=true
		fi
	done
}

##
## Notify the starting time of backup
##
function startScript {
	echo "-----------------------------------------------------"
	echo "START - ${VM}"
	echo "Host: ${HOST}"
	echo "Date: `date`"
	echo "-----------------------------------------------------"
	echo
}

##
## Notify the finishing time of backup
##
function finishScript {
	echo
	echo "-----------------------------------------------------"
	echo "FINISH - ${VM}"
	echo "Host: ${HOST}"
	echo "Date: `date`"
	echo "-----------------------------------------------------"
}

##
## Start VM if suspened
##
function doStart {
	## Check state of VM
	VMSTATE=`VBoxManage showvminfo "${VM}" --machinereadable | grep "^\(VMState=\)" | cut -d'"' -f2 2>/dev/null`

	if [ "${VMSTATE}" != "running" ]; then
		echo "Starting ${VM} . . ."
		## Resume VMs which were running [--type gui|sdl|vrdp|headless]
		VBoxManage startvm ${VM} --type headless
		echo "${VM} Resumed on `date`"
	else
		echo "${VM} was not running, not resuming - `date`"
	fi
	echo
}

#################################################################
## Script

## Start loop
for VM in ${VMLIST}; do
	sleep 1
## Check exempt list
	doCheckExempt
	if [ "$VM_EXEMPT" = "false" ]; then
		startScript
	## Start if suspended
		doStart
		sleep 3
		finishScript
	fi
## Reset exemption
	VM_EXEMPT=false
	shift
done

#################################################################
