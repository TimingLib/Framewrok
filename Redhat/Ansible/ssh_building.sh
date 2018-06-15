#/bin/bash

Work_folder=`pwd`/worker
Hosts_path=`pwd`/ansible_hosts
export ANSIBLE_HOSTS=$Hosts_path
#Establishing the SSH link between your control machine and the target machines.


#Generate the rsa.
generate_rsa(){
/usr/bin/expect <<EOF
spawn ssh-keygen
expect {
"/.ssh/id_rsa):" {send "\r";exp_continue}
"Overwrite (y/n)?" {send "\r"}
"passphrase):" {send "\r";exp_continue}
"passphrase again:" {send "\r"}
}
expect eof
EOF
}

#Copy the rsa_pub to the target machines

cp_rsa(){
/usr/bin/expect <<EOF
spawn ansible-playbook $Work_folder/cluster_ssh.yaml -f 20 -u root --ask-pass -c paramiko
expect {
"SSH password:" {send "labview===\r";exp_continue}
"(yes/no)?" {send "yes\r";exp_continue}
}

expect eof
EOF
}


generate_rsa > /dev/null

if [ $# = 0 ];
	then
		echo -e "\e[34mSYNOPSIS\e[0m \n\tssh_building.sh [ALL/all]... [NAME/IP]..."
		echo -e "\e[34mDESCRIPTION\e[0m"
		echo -e "\t[ALL/all]	Building the connection with all the compile machines."
		echo -e "\t[NAME/IP]	Building the connection with the specified machine."
		exit
	else
		if [ $1 = all -o $1 = ALL ];then
			if [ -f ~/.ssh/known_hosts ];then
			sleep 1
			cp_rsa  2>/dev/null
			exit 10
			else
			touch ~/.ssh/known_hosts
			cp_rsa 2>/dev/null
			exit 11
			fi
		else
			echo -e ""
			echo -e "\e[31m------------------------------------------\e[0m"
			echo -e ""
			ansible $1 -m authorized_key -a "user=root key='{{ lookup('file','/home/ni/.ssh/id_rsa.pub') }}'  path=/root/.ssh/authorized_keys manage_dir=no" -u root --ask-pass -c paramiko
		fi
fi
