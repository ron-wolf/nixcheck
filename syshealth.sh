#!/bin/bash

# define true and false
TRUE=1
FALSE=2

# state flags
CHECK_NIC=$FALSE
CHECK_DISK_USAGE=$FALSE
CHECK_PORT_LISTEN=$FALSE
PORT=0;

# check to see if the number of arguments is valid
if [ "$#" -lt 1 ]; then
	echo "Not enough arguements.";
	exit 1;
elif [ "$#" -gt 4 ]; then
	echo "Too many arguements.";
	exit 1;
fi

# parse command line arguments
for (( i=1; i <= $# ; ++i )); do
	case "${!i}" in
	"-p")
		# the argument immediately following the -p flag must be a port number
		next=`expr $i + 1`;
		if ! [[ ${!next} =~ ^[0-9]+$ ]] || [ "$i" -eq "$#" ]; then
			echo "You must specify a port number after -p";
			echo "Exiting.";
			exit 1;
		elif [ $CHECK_PORT_LISTEN = $TRUE ]; then
			echo "Can't specify options twice.";
			echo "Exiting.";
			exit 1;
		fi
		CHECK_PORT_LISTEN=$TRUE;
		PORT=${!next};
		i=$next;
		;;
	"-d")
		CHECK_DISK_USAGE=$TRUE;
		;;
	"-n")
		CHECK_NIC=$TRUE;
		;;
	*)
		echo "Invalid option: ${!i}";
		echo "Exiting.";
		exit 1;
		;;
	esac
done

# output state information
[[ $CHECK_NIC = $TRUE ]] && status_message="ON" ||  status_message="OFF";
echo "check_nic_health => $status_message";
[[ $CHECK_DISK_USAGE = $TRUE ]] && status_message="ON" || status_message="OFF";
echo "check_disk_usage => $status_message";
[[ $CHECK_PORT_LISTEN = $TRUE ]] && status_message="ON" || status_message="OFF";
echo "check_port_listen => $status_message";

