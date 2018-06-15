#!/bin/bash

Work_folder=`pwd`/worker
Hosts_path=`pwd`/ansible_hosts
export ANSIBLE_HOSTS=$Hosts_path

#Excute the image clone and restore

Usage(){
        echo -e "\e[34mSYNOPSIS\e[0m\n\tcluster_image.sh [OPTIONS]... [NAME/IP]..."
	echo -e "\e[34mDESCRIPTION\e[0m"
        echo -e "\t-h	Give the help list. "  
	echo -e "\t-r	Restore the whole disk from the image on the server to all the workers."
        echo -e "\t-s [NAME/IP]	Save the whole disk of the specail machine to the image on the server." 
}

Select_name(){
ls /var/tmp/ |grep Image_Info.csv >/dev/null||sudo mount -t cifs -o user=Farm,pass=Labview===  //SH-RD-TimingLib/Images /var/tmp/ || exit 55
menu=(${menu[@]} `ls -1 /var/tmp|grep -v "Image*"|tr -s "\n" " "`)
i=1
	for name in ${menu[@]}
		do
		  echo -e "\e[31m$i : $name\e[0m"
		  ((i++))
	done
	read -t 60 -p "Please selcet the image_name:" choice
	if [ ! $choice ];then
		name_image=${menu[$choice]}
		echo -e "\n\e[31mThe $name_image image will overwrite the disk of the workers.\e[0m"
	else
		let element=$choice-1
		name_image=${menu[$element]}
		echo -e "\n\e[31mThe $name_image image will overwrite the disk of the workers.\e[0m"
	fi	
sudo umount /var/tmp
}

Restore_img(){
sed -i "s#\(shell:\).*#\1 /tmp/image_clone.sh -r $1#"  $Work_folder/cluster_image_restore.yaml
ansible-playbook $Work_folder/cluster_image.yaml -f 20
}

#Make sure the server online

Save_img(){
ansible $1 -m copy -a "force=yes src="$Work_folder/image_clone.sh" dest="/tmp/image_clone.sh" owner=root mode=0555" -u root
ansible $1 -m shell -a "/tmp/image_clone.sh -s" -u root
}


ping -c 1 SH-RD-TimingLib 1>/dev/null 2>&1

if [ $? = 0 ];then
	if [ $# = 0 ];then
		Usage
		exit 55
		else
		while getopts :rs: opt
			 do
				case $opt in
				 r) Select_name
				    Restore_img $name_image;;
				 s) Save_img $OPTARG ;;
				\?) Usage
				    exit 66    ;;
				esac
		done
	fi
	else
		echo "====================================================="
		echo -e  "\e[31mThe server is onffline,Please check the network.\e[0m"
		echo "====================================================="
		exit 22
fi
