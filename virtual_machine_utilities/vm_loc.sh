#!/bin/bash

# A simple script to start/shutdown local virtual machines (QEMU/KVM).
# You can also use this script to run commands on all VMs and to upload
# files to all VMs in parallel. 

# List of VMs that you want to use. 
vms=(ubuntu18.04_vm0 ubuntu18.04_vm1 ubuntu18.04_vm2)

IFS='
'
vmstatus=$(virsh list --all)
vminfo=$(virsh net-dhcp-leases default)
declare -A vmstatus_map
declare -A vminfo_map

# Gather states of each VM.
i=0
j=0
for line in $vmstatus; do
    if (( $i > 1 )); then
        name=$( echo $line | awk '{ print $2 }' )
        state=$( echo $line | awk '{ print $3 }' )
        vmstatus_map[$name]=$state
    fi
    i=$((i + 1))
done

# Get IP addresses of each VM.
guests=""
for vm in "${vms[@]}"; do
    if [ -v vmstatus_map[$vm] ] && 
    [ ${vmstatus_map[$vm]} == "running" ]; then
        guests="$(virsh domifaddr $vm | awk 'NR>2 { print $4 }' | 
        awk -F/ '{ print $1 }') ${guests}"
    fi
done


if [ -z "$1" ]; then
    # If no arguments given, display basic VM info.
    virsh list --all
    virsh net-dhcp-leases default
else
    while getopts 'c:d:is' OPTION; do
    case "$OPTION" in
        # Run a shell command on each VM. Run the command without
        # sudo. Assumes all VMs are associated with the same username.
        c)
        stty -echo; printf "Password: "; read PASS; stty echo; echo "${PASS}" \
        | parallel-ssh -vAi -O StrictHostKeyChecking=no \
        -H $guests -t 0 -l "scottvm" -I "sudo -S sh -c \"${OPTARG}\""
        ;;
        
        # Upload files to each VM.
        d)
        parallel-scp -vAr -O StrictHostKeyChecking=no -H $guests -l "scottvm" \
        $OPTARG /home/scottvm/
        ;;
        
        # Start each VM.
        i)
        for vm in "${vms[@]}"; do
            if [ -v vmstatus_map[$vm] ] && 
            [ ${vmstatus_map[$vm]} == "shut" ]; then
                virsh start $vm
            fi
        done
        ;;
        
        # Shutdown each VM.
        s)
        for vm in "${vms[@]}"; do
            if [ -v vmstatus_map[$vm] ] && 
            [ ${vmstatus_map[$vm]} == "running" ]; then
                virsh shutdown $vm
            fi
        done
        ;;

    esac
    done
fi

# Start virt-manager to interact with the VMs.
if [ -z $(pgrep virt-manager) ]; then
    virt-manager
fi