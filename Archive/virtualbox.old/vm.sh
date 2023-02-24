#!/bin/bash

##
## For VirtualBox
## Check Status of Machines
##
echo "-----------------------------------------------------"
for VM in `VBoxManage list vms | grep '"' | cut -d'"' -f2 2>/dev/null`; do
	echo "VM: ${VM}"
	LOCATION=`VBoxManage showvminfo ${VM} --machinereadable | grep ".vdi" | cut -d'"' -f4 2>/dev/null`
	XMLFILE=`VBoxManage showvminfo "${VM}" --machinereadable | grep "^\(CfgFile=\)" | cut -d'"' -f2 2>/dev/null`
	echo "LOCATION - vdi: ${LOCATION}"
	echo "LOCATION - XML: ${XMLFILE}"
	VMSTATE=`VBoxManage showvminfo "${VM}" --machinereadable | grep "^\(VMState=\)" | cut -d'"' -f2 2>/dev/null`
	echo "VM CURRENT STATE: ${VMSTATE}"
	echo "-----------------------------------------------------"
	shift
done
