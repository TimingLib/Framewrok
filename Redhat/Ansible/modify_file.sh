#!/bin/bash


Work_folder=`pwd`/worker
Hosts_path=`pwd`/ansible_hosts
export ANSIBLE_HOSTS=$Hosts_path

#This scripts is aimed to paste and copy files.

Usage(){
	echo -e "\e[34mSYNOPSIS\e[0m\n\tmodify_file.sh [OPTIONS]... [PATH]... to [PATH]..."
	echo -e "\e[34mDESCRIPTION\e[0m"
	echo -e "\t-h Give the help list. "  
	echo -e "\t-c Copy the local file to the specal machines."
	echo -e "\t-s Copy the file on the //SH-RD-TimingLib/ to the specal machines." 
	echo -e "\t-d Delete the file from the specal machines."
} 

yaml=$Work_folder/cluster_file.yaml

if [ $# -eq 0 ];then

		Usage
		exit 0
	else
		case $1 in
			-h)	Usage
				exit 1 ;;
			-c)	if [ $# -eq 3 ];then
						sed -i '/-\ name:\ Copy/,+7s/^#//' $yaml
						sed -i  's#\(^\ *src_path:\).*#\1\ '$2'#'  $yaml
						sed -i  's#\(^\ *dest_path:\).*#\1\ '$3'#'  $yaml
						ansible-playbook $yaml  -f 20
						sed -i  '/-\ name:\ Copy/, +7s/^/#/' $yaml
					else
						Usage
						exit 2
				fi ;;
			-d)     if [ $# -eq 2 ];then
						sed -i '/-\ name:\ Del/,+6s/^#//' $yaml
						sed -i  's#\(^\ *dest_path:\).*#\1\ '$2'#'  $yaml
						ansible-playbook $yaml  -f 20
						sed -i  '/-\ name:\ Del/, +6s/^/#/' $yaml
					else
						Usage
						exit 3
				fi ;;
			-s)	if [ $#  -eq 3 ];then
						sed -i '/-\ name:\ Scp/,+9s/^#//' $yaml
						sed -i  's#\(^\ *src_path:\).*#\1\ '$2'#'  $yaml
						sed -i  's#\(^\ *dest_path:\).*#\1\ '$3'#'  $yaml
						ansible-playbook $yaml  -f 20
						sed -i  '/-\ name:\ Scp/, +9s/^/#/' $yaml
					else
						Usage 
						exit 4
				fi ;;	
		esac

fi

