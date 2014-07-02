#!/bin/bash

# state flags
CHECK_NIC=false
CHECK_DISK_USAGE=false
CHECK_PORT_LISTEN=false
PORT=0;

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
	"-p")
		# the argument immediately following the -p flag must be a port number
		next=`expr $i + 1`;
		if ! [[ ${!next} =~ ^[0-9]+$ ]] || [ "$i" -eq "$#" ]; then
			echo "You must specify a port number after -p";
			echo "Exiting.";
			exit 1;
		elif [ $CHECK_PORT_LISTEN = true ]; then
			echo "Can't specify options twice.";
			echo "Exiting.";
			exit 1;
		fi
		CHECK_PORT_LISTEN=true;
		PORT=${!next};
		i=$next;
		;;
	"-d")
		CHECK_DISK_USAGE=true;
		;;
	"-n")
		CHECK_NIC=true;
		;;
	*)
		echo "Invalid option: ${!i}";
		echo "Exiting.";
		exit 1;
		;;
	esac
done

# output state information
[[ $CHECK_NIC = true ]] && status_message="ON" ||  status_message="OFF";
echo "check_nic_health => $status_message";
[[ $CHECK_DISK_USAGE = true ]] && status_message="ON" || status_message="OFF";
echo "check_disk_usage => $status_message";
[[ $CHECK_PORT_LISTEN = true ]] && status_message="ON" || status_message="OFF";
echo "check_port_listen => $status_message";

if [ $CHECK_PORT_LISTEN = true ]; then

	# CHECK IF SPECIED PORT IS LISTENING
	
	# query netstat for the specified port
	result=`netstat -plnt | grep "0:$PORT "`;
	
	# check if port is listening
	if [ -n "$result" ]; then
		service=`echo "$result" | awk '{print $7}' | cut -d'/' -f2`;
		echo "$service is LISTENING on port $PORT";
	else
		echo "Port is not listening.";
	fi
fi
