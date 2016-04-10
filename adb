#!/bin/bash
ADB_BIN="/usr/local/bin/adb"
IFS=$'\n'
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
ADB_LIST="$HOME/.adb_list"
$ADB_BIN start-server
if [[ $1 == -* ]]
then
	$ADB_BIN $*
else

	if [ $1 == "devices" ]
	then
		$ADB_BIN devices -l
	elif [ $1 == "list" ]
	then
		if [ -f $ADB_LIST ]
		then
			printf '%-15s : %-10s : %-20s \n' $GREEN"ADB Status" "DeviceName" "Device SerialNo"$NORMAL;
			#cat ~/.adb_list
			# should actually print all devices name and serial number along with current status
			while read p;
			do
				OIFS=$IFS
				IFS=';'
				arr=( $p )
		  		#echo ${arr[1]}
		  		IFS=$OIFS
		  		adb_status=`$ADB_BIN -s ${arr[1]} get-state`
		  		#echo $adb_status ":" ${arr[0]} " : " ${arr[1]}
		  		if [ $adb_status == "unknown" ]
		  		then
		  			printf '%-15s : %-10s : %-20s \n' "$RED$adb_status" ${arr[0]} "${arr[1]}$NORMAL";
		  		elif [ $adb_status == "bootloader" ]
		  		then
		  			printf '%-15s : %-10s : %-20s \n' "$BLUE$adb_status" ${arr[0]} "${arr[1]}$NORMAL";
				elif [ $adb_status == "device" ]
				then
		  			printf '%-15s : %-10s : %-20s \n' "$GREEN$adb_status" ${arr[0]} "${arr[1]}$NORMAL";
		  		else
		  			printf '%-15s : %-10s : %-20s \n' $adb_status ${arr[0]} ${arr[1]};
				fi
		 	done<$ADB_LIST
		 	exit
		 else
		 	echo "The list file is not present please create a file at $ADB_LIST"
		 	echo "File format is as listed below"
		 	echo "NAME;SerialNo/IPAddress:PORT"
		 	echo "Ensure its one device per line"
		 	exit
		 fi
	else
		if [ -f $ADB_LIST ]
		then
			adb_item=`grep "$1;" $ADB_LIST | cut -d";" -f2`
			if [ ! -z $adb_item ]
			then
				shift
				if [ $# -lt 1 ]
				then
					echo "Device name listed but no argument specified"
				else
					$ADB_BIN -s $adb_item $@
				fi
			else
				$ADB_BIN $@
			fi
		else
			$ADB_BIN $@
		fi
	fi
fi