#!/bin/bash

# state flags
CHECK_NIC=false
CHECK_DISK_USAGE=false
CHECK_LSERVICES=false
CHECK_NETOWRK=false
DEVICE=0;

function duplicate_args_err {

	echo "You already entered $1 as an argument.";
	echo "Can't specify arguments twice.";
}
# check to see if the number of arguments is valid
if [ "$#" -lt 1 ]; then
	echo "Not enough arguments.";
	exit 1;
elif [ "$#" -gt 4 ]; then
	echo "Too many arguments.";
	exit 1;
fi

# parse command line arguments
for (( i=1; i <= $# ; ++i )); do
	case "${!i}" in
	"-i")
		if [ CHECK_NIC = true ]; then
			duplicate_args_err ${!i};
		fi
		CHECK_NIC=true;
		;;
	"-n")
		if [ CHECK_NETWORK = true ]; then
			duplicate_args_err ${!i};
		fi
		CHECK_NETWORK=true;
		;;
	"-d")
		if [ CHECK_DISK_USAGE = true ]; then
			duplicate_args_err ${!i};
		fi
		CHECK_DISK_USAGE=true;
		;;
	"-l")
		if [ CHECK_LSERVICES = true ]; then
			duplicate_args_err ${!i};
		fi
		CHECK_LSERVICES=true;
		;;
	*)
		echo "Invalid option: ${!i}";
		echo "Exiting.";
		exit 1;
		;;
	esac
done

# output state information
echo;
[[ $CHECK_NIC = true ]] && status_message="ON" ||  status_message="OFF";
echo "check_nic_health => $status_message";
[[ $CHECK_DISK_USAGE = true ]] && status_message="ON" || status_message="OFF";
echo "check_disk_usage => $status_message";
[[ $CHECK_LSERVICES = true ]] && status_message="ON" || status_message="OFF";
echo "check_lservices => $status_message";
[[ $CHECK_NETWORK = true ]] && status_message="ON" || status_message="OFF";
echo "check_NETWORK => $status_message";
echo;

# display listening services
if [ $CHECK_LSERVICES = true ]; then
	
	echo "PRINTING LISTENING SERVICES";
	echo;

	result=`lsof -i | grep LISTEN`;
	if [ -n "$result" ]; then
		echo "$result";
		echo;
	else
		echo "This machine does not appear to be running any services.";
		echo;
	fi
fi
if [ $CHECK_NIC = true ]; then
	devices=`ip link show | awk 'NR%2==1' | awk '{ print $2 }' | sed 's/://'`;
	for d in $devices; do
		result=`ethtool "$d"`;
		echo "PRINTING INFORMATION FOR DEVICE: $d";
		echo;
		echo "    $result";
		echo;
		
	done
fi
if [ $CHECK_NETWORK = true ]; then
	echo "PRINTING NETWORK INFORMATION";
	echo;

	result=`ifconfig`;
	echo "    $result";
	echo;
fi
