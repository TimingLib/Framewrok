#!/bin/bash

Work_folder=`pwd`/worker
Hosts_path=`pwd`/ansible_hosts
export ANSIBLE_HOSTS=$Hosts_path

#Reboot the target machines

Usage(){
	echo -e "\e[34mSYNOPSIS\e[0m\n\treboot_worker.sh [ALL/all]...  [NAME/IP]..."
	echo -e "\e[34mDESCRIPTION\e[0m"
	echo -e "\t[ALL/all]	reboot all the compile machines." 
        echo -e "\t[NAME/IP]	reboot the special machine." 
}
if [ $# -eq 1 ];
	then
		if [ $1 == all -o $1 == ALL ];then
			echo " "
			echo -n "Are you sure to reboot all the compile workers? Yy/Nn "
			read   choice
			case $choice in
		   	 y|Y)
				ansible-playbook $Work_folder/cluster_reboot.yaml -f 20
				exit ;;
		   	 n|N)
				exit 55;;
			esac
		else
			ansible $1 -m command -a "reboot" -u root
			exit 44
		fi
	else 
		Usage
fi

