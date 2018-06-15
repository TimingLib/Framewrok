#/bin/bash

Work_folder=`pwd`/worker
Hosts_path=`pwd`/ansible_hosts
export ANSIBLE_HOSTS=$Hosts_path
usage() {
	echo -e "\e[34mDESCRIPTION\e[0m"
	echo -e "\tList the versions of the OS,Vivado,ISE...eg" 
	echo -e "Watiing ...  ...  ..."
}


usage
ansible-playbook $Work_folder/cluster_version.yaml -f 20  1>/dev/null
ansible all -m shell -a "/tmp/version.sh" -u root
