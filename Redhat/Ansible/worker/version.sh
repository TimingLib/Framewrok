#!/bin/bash

#fetch the version on the target machines

os_version=`lsb_release -a|grep Description|awk -F "\t" '{print $2}'`
worker_version=`yum list all|grep compileworker|awk '{print $2}'`
vivado_folder=(`ls /usr/local/natinst/NIFPGA/programs|tr -s "\n" " "`)
for i in ${vivado_folder[@]};do
    vivado_version=(${vivado_version[@]} `/usr/local/natinst/NIFPGA/programs/$i/bin/vivado -version|grep Vivado|awk '{print $2$3}'`)
done

echo "System version: $os_version" 
echo "Worker version: $worker_version" 
echo "Vivado version: ${vivado_version[@]}" 
