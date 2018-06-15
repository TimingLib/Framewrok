#!/bin/bash

#author Yang
####################Warning###############################
#This script will restore/save the whole disk from the server automaticlly
#after you finished the args setting.So once running ,it cannot be stopped.
#Please consider it carefully.
##########################################################
#Please run the script as root.

export PATH=$PATH
Linux_version=`lsb_release -d|awk '{print $2$3$8}'`
Vivado_version=`ls /usr/local/natinst/NIFPGA/programs`
Vivado_version_name=`echo $Vivado_version|tr -s " " "&"`
Worker_version=`yum list installed|grep nifpgacompileworker|awk '{print $2}'`
System_version=`cat /etc/issue|grep "Red Hat"`
Saved_name=${Linux_version}_${Vivado_version_name}_$(date +%y%m%d-%H%M)
Config_grub=/boot/efi/EFI/redhat/grub.conf

for dir in $Vivado_version;do
	Vivado_version_details=(${Vivado_version_details[@]} `/usr/local/natinst/NIFPGA/programs/$dir/bin/vivado -version|grep Vivado|awk '{print $2$3}'`)
done


Usage(){
	echo -e "\e[34mSYNOPSIS\e[0m\n\timage_clone.sh [OPTIONS]"
	echo -e "\e[34mDESCRIPTION\e[0m"
	echo -e "\t- h	Give the help list."  
	echo -e "\t- r	Restore the whole disk from the image on the server."
	echo -e "\t- s	Save the whole disk to the image on the server." 
#	echo -e "\t[NAME]	(Optional parameter)The name of the image what you want to save/restore."
} 


#save the disk to image on the image_server.

Save_disk(){
#ping -c 1  SH-RD-TimingLib 1>/dev/null||echo -e "\033[31mThe image server is offline,please check the network.\033[0m"
sed -i 's/\=0/\=1/' $Config_grub
sed -i '/splashimage/a hiddenmenu' $Config_grub
sed -i '/Clonezilla/,$d' $Config_grub
cat <<EOF   >>$Config_grub
 title Clonezilla  live
 root (hd0,1)
 kernel /clonezilla/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nolocales edd=on nomodeset nodmraid ocs_prerun1="sudo dhclient -v enp2s0" ocs_prerun2="sudo dhclient -v enp5s0" ocs_prerun5="sudo mount /dev/sda1  /mnt" ocs_prerun6="sleep 4" ocs_prerun7="sudo cp -f /mnt/EFI/redhat/grub.conf.bak /mnt/EFI/redhat/grub.conf" ocs_prerun8="sudo umount /mnt/" ocs_prerun9="sleep 4" ocs_prerun3="sudo mount -t cifs -o user=Farm,pass=Labview===  //SH-RD-TimingLib/Images  /home/partimag/" ocs_prerun4="sleep 4" ocs_live_run="sudo /usr/sbin/ocs-sr -q2 -j2 -z1p -sc -p reboot savedisk $1 sda" live_batch="yes" locales=en_US.UTF-8 keyboard-layouts=NONE vga=788 ip=frommedia nosplash live-media-path=/clonezilla/live  bootfrom=/dev/sda1 toram=filesystem.squashfs
initrd /clonezilla/live/initrd.img
boot
EOF
}


#restore the disk from image on the image_server

Restore_disk(){
#ping -c  1 SH-RD-TimingLib 1>/dev/null||echo -e "\033[31mThe image server is offline,please check the network.\033[0m"
sed -i 's/\=0/\=1/' $Config_grub
sed -i  '/splashimage/a hiddenmenu' $Config_grub
sed -i '/Clonezilla/,$d' $Config_grub
cat <<EOF   >>$Config_grub
 title Clonezilla  live
 root (hd0,1)
 kernel /clonezilla/live/vmlinuz boot=live union=overlay username=user config components quiet noswap nolocales edd=on nomodeset nodmraid ocs_prerun1="sudo dhclient -v enp2s0" ocs_prerun2="sudo dhclient -v enp5s0" ocs_prerun3="sudo mount -t cifs -o user=Farm,pass=Labview=== //SH-RD-TimingLib/images  /home/partimag/" ocs_prerun4="sleep 4" ocs_live_run="sudo /usr/sbin/ocs-sr -e1 auto -e2 -r -j2 -p reboot restoredisk $1 sda" live_batch="yes" locales=en_US.UTF-8 keyboard-layouts=NONE vga=788 ip=frommedia nosplash live-media-path=/clonezilla/live  bootfrom=/dev/sda1 toram=filesystem.squashfs
initrd /clonezilla/live/initrd.img
boot
EOF
}

#list the image name on the image_server

Select_name(){
#export the image_name from the server to aviod the wrong input
echo -e "\n"
menu=(${menu[@]} `ls -1 /var/tmp|grep -v "Image*" |tr -s "\n" " "`)
i=1
for name in ${menu[@]/Image_Info.csv/}
	do
		echo -e "$i : $name"
		notes=`cat /var/tmp/Image_Info*|grep -A 5  "$name"|sed '1d'|sed '1,$ s/^/\\t/'`
		echo -e "\e[34m$notes\e[0m"
		((i++))
	done
read -t 60 -p "Please selcet the image_name:" choice
if [ !  $choice  ];then
		name_image=${menu[$choice]}
		echo -e "\n\e[31mThe ${name_image} image will overwrite the local disk.\e[0m"
	else
		let element=$choice-1
		name_image=${menu[$element]}
		echo -e "\e[31mThe ${name_image} image will overwite the local disk.\e[0m"
fi
}

#mount the image server on /var/tmp

Mount_server(){
ping -c 1 SH-RD-TimingLib &>/dev/null
if [ $? == 0 ];then
		sudo mount -l|grep "SH-RD-TimingLib" 1>/dev/null  2>&1||sudo mount -t cifs -o username=Farm,password=Labview===  //SH-RD-TimingLib/Images  /var/tmp
	else
		echo -e "\e[31m==== The IMAGE SERVER is offline,please check the network! ====\e[0m"
		exit 51
fi
}

#clear the notes.csv invalid information

Clear_info(){
title=`cat /var/tmp/Image_Info.csv|grep Title|awk -F ":" '{print $2}'|tr -s "\n\r" " "`
menu=(Timing_Lib  $Saved_name  `ls -1 /var/tmp |tr -s "\n" " "`)
for abc in $title
	do
		if [[ ${menu[@]/${abc}/} == ${menu[@]} ]]
			then
				sed -i "/$abc/,/comments:/d" /var/tmp/Image_Info.csv
		fi
done
umount /var/tmp
}


#input the image info 

Input(){
#sudo mount -t cifs -o username=Farm,password=Labview===  //SH-RD-TimingLib/Images  /var/tmp 
#echo -e "\e[34mOS Version :\e[0m\c"
#read -t 40  Os
#echo -e "\e[34mWorker Version :\e[0m\c"
#read -t 40  Wo
#echo -e "\e[34mVivado Version :\e[0m\c"
#read -t 40  Vi
#echo -e "\e[34mImage Date :\e[0m\c"
#read -t 40  Im
echo -e "\e[34mComments :\e[0m\c"
read -t 120  Coment
}


#main

if [ $# -eq 0 ]
	then	
		Usage
		exit 5
	else 
		Mount_server
		while getopts :r:sh opt
			do
				case $opt in
					s)	echo -e "Disk to Image (\e[31m${Saved_name}\e[0m) as image_name"
						Save_disk ${Saved_name} 
						Input
						echo -e "\nTitle :$Saved_name\nOS Version :${System_version}\nWorker Version :${Worker_version}\nVivado Version :${Vivado_version_details[@]}\nImage Date :$(date +%F\ %T)\nComments :$Coment\n" >>/var/tmp/Image_Info.csv;;
					\:)	echo -e "Image to Disk (\e[31mFirst_image\e[0m as default image)"
						Select_name
						Restore_disk ${name_image} ;;
					r)	echo -e "Image to Disk (\e[31m$OPTARG\e[0m as default image)"
						ls -1 /var/tmp |grep $OPTARG 1>/dev/null 2>&1
						if [ $? = 0 ];then
								Restore_disk $OPTARG
							else 
								echo -e "\e[031m$OPTARG\e[0m not exist on the server."
								exit 55
						fi ;;
					h)	Usage 
						exit 0 ;;
					\?)	echo -e "\e[31mInvalid Option\e[0m" 
						Usage
						exit 21 ;;
				esac
		done
fi

Clear_info

ne=\>\>\>\>		 
for ((i=0;i<=50;i+=6)); do
	printf "\033[31m[%-50s]\033[0m\r" $ne
	sleep 0.1
	ne=\>\>\>\>\>$ne
done

echo -e "\n"	
for i in {5..1};do
	sleep 1
	echo  -e  "\033[31mWarning: the system will reboot --  ${i}s \033[0m"
done

reboot
