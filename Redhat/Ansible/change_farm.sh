#!/bin/bash

Work_folder=`pwd`/worker
Hosts_path=`pwd`/ansible_hosts
export ANSIBLE_HOSTS=$Hosts_path

usage(){
echo -e "\e[34mDESCRIPTION\[0m"
echo -e "\tSwitch the connections of the Compile-workers to the new Compile-Farm."
}

input(){
read -p "Please input the Compile-Farm name :" name
echo ""
echo "All the Compile-workers will connect to $name"
echo ""
}

line(){
char=\#
i=1
while (($i<50));do 
	printf "%-40s\r" $char
	char=\#$char
	((i++))
	sleep 0.1
done
echo -e "\r"
}

if [ $# != 0 ]
	then
		echo "PLease excute the script without any options."
		exit
	else
		usage
		input
		server=`ssh root@sh-rd-tl01 "sed -n 6p /usr/local/natinst/nifpgacompileworker/configuration/NIFarmInfo.xml"`
		farm=${server:0-26:15}
		if [ $farm = $name ] ;then
			echo "All the workers have connected this Farm"
			exit
			else
#      		        farm=`echo $server|awk -F '>'  '{print $2}'|awk -F '<' '{print $1}'`
			ansible all -m command -a "sed -i 's/"$farm"/"$name"/' /usr/local/natinst/nifpgacompileworker/configuration/NIFarmInfo.xml" -u root
			ansible all -m command -a "reboot" -u root
			line
			echo "Done ~ The Compile-Farm has changed to $farm"
#			echo $farm
		fi
fi
