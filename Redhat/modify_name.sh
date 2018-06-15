#!/bin/bash

#This script will modify the name of machine after every restored image.

#enable sudo

#do=/etc/sudoers
#chmod +w $do
#sed -i '/root.*ALL/a worker ALL=(ALL) ALL' $do
#sed -i '/\# %wheel.*NOPASSWD: ALL/c %wheel   ALL=(ALL)   NOPASSWD:ALL' $do
#sed -i '/Defaults.*requiretty/c \# Defaults requiretty' $do
#chmod -w $do
#usermod -aG wheel worker

#change the name

declare -a  mac
declare -a  ipv4
#This is a dictionary of the testing machine name.(Specify the machine corresponding to a unique hostname)
mac=([90:2B:34:35:73:FF]="sh-rd-tl01" [90:2B:34:34:A9:10]="sh-rd-tl02" [90:2B:34:34:7B:51]="sh-rd-tl03" [90:2B:34:34:7C:11]="sh-rd-tl04" [90:2B:34:18:96:74]="sh-rd-tl05" [90:2B:34:34:A8:DA]="sh-rd-tl06" [90:2B:34:34:7B:EA]="sh-rd-tl07" [90:2B:34:34:7B:E8]="sh-rd-tl08" [90:2B:34:34:7D:9C]="sh-rd-tl09" [40:8D:5C:71:0F:70]="sh-rd-tl11" [40:8D:5C:4E:3F:F5]="sh-rd-tl12" [40:8D:5C:74:E7:33]="sh-rd-tl13" [40:8D:5C:72:55:FC]="sh-rd-tl14" [40:8D:5C:72:53:04]="sh-rd-tl15" [40:8D:5C:72:56:40]="sh-rd-tl16" [40:8D:5C:72:56:61]="sh-rd-tl17" [40:8D:5C:74:EB:B4]="sh-rd-tl18" [00:0C:29:95:C0:BC]="blue" [78:2B:CB:B5:18:77]="sh-rd-tl10")
#This is a dictionary of the testing machine ipv4.(Disable the DHCP to aviod the lost dnslookup)
ipv4=([90:2B:34:35:73:FF]="10.144.16.158" [90:2B:34:34:A9:10]="10.144.16.111" [90:2B:34:34:7B:51]="10.144.16.153" [90:2B:34:34:7C:11]="10.144.16.227" [90:2B:34:18:96:74]="10.144.16.212" [90:2B:34:34:A8:DA]="10.144.16.205" [90:2B:34:34:7B:EA]="10.144.16.210" [90:2B:34:34:7B:E8]="10.144.16.213" [90:2B:34:34:7D:9C]="10.144.16.214" [40:8D:5C:71:0F:70]="10.144.16.248" [40:8D:5C:4E:3F:F5]="10.144.16.245" [40:8D:5C:74:E7:33]="10.144.16.250" [40:8D:5C:72:55:FC]="10.144.16.177" [40:8D:5C:72:53:04]="10.144.16.233" [40:8D:5C:72:56:40]="10.144.16.74" [40:8D:5C:72:56:61]="10.144.16.231" [40:8D:5C:74:EB:B4]="10.144.16.249" [00:0C:29:95:C0:BC]="10.144.16.125" [78:2B:CB:B5:18:77]="10.144.16.236")
#You  only need to  update the dict when you want to setup a new machine in the laboratory.

local_mac=`ifconfig |grep HWaddr|awk '{print $5}'`
local_name=`hostname|awk -F "." '{print $1}'`
#echo $local_name
#echo $local_mac
#echo ${!mac[@]}
#for key in ${!mac[@]}
#	do
#         if [ $key == $local_mac ];then
#			echo ${mac[$key]}
if [[ "${!mac[@]/$local_mac/]}" != "${!mac[@]}" ]] ;then
			host_name=${mac[$local_mac]}
			local_ip=${ipv4[$local_mac]}
#			echo $local_ip
#			echo $host_name
				if [[ $local_name != $host_name ]];then
					sed -i "s/HOSTNAME.*/HOSTNAME=${host_name}.apac.corp.natinst.com/" /etc/sysconfig/network
					sed -i '$a GATEWAY=10.144.16.1' /etc/sysconfig/network
					sed -i 's/\(BOOTPROTO\).*/\1=static/' /etc/sysconfig/network-scripts/ifcfg-eth0
					sed -i '$a IPADDR='${local_ip}'' /etc/sysconfig/network-scripts/ifcfg-eth0
					sed -i '/IPADDR/a DNS2=130.164.12.30' /etc/sysconfig/network-scripts/ifcfg-eth0
					sed -i '/IPADDR/a DNS1=130.164.213.50' /etc/sysconfig/network-scripts/ifcfg-eth0
					sed -i '/IPADDR/a DOMAIN=apac.corp.natinst.com' /etc/sysconfig/network-scripts/ifcfg-eth0
#					sed -i '/IPADDR/a NETMASK=255.255.255.0' /etc/sysconfig/network-scripts/ifcfg-eth0
					sed -i '/IPADDR/a PEERDNS=yes' /etc/sysconfig/network-scripts/ifcfg-eth0
					sed -i '$a 127.0.0.1 '${host_name}'  '${host_name}.apac.corp.natinst.com'' /etc/hosts
					sleep 1
#					service network restart
					reboot
				fi
#			echo "This machine is not in the list of  HWaddr book."
#			echo "Please check the netcard."
	else
        		sed -i '$a echo "This machine is not in the list of HWaddr book."' /etc/bashrc
fi
