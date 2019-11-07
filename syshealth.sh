#!/bin/bash

# state flags
CHECK_NIC=false
CHECK_DISK_USAGE=false
CHECK_LSERVICES=false
CHECK_NETWORK=false
# DEVICE=0

function duplicate_args_err {

	echo "You already entered $1 as an argument.";
	echo "Can't specify arguments twice.";
}
# check to see if the number of arguments is valid
if [[ "$#" -lt 1 ]]; then
	echo "Not enough arguments.";
	exit 1;
elif [[ "$#" -gt 4 ]]; then
	echo "Too many arguments.";
	exit 1;
fi

# parse command line arguments
for (( i=1; i <= $# ; ++i )); do
	case "${!i}" in
	"-i")
		if $CHECK_NIC; then
			duplicate_args_err ${!i};
		fi
		CHECK_NIC=true;
		;;
	"-n")
		if $CHECK_NETWORK; then
			duplicate_args_err ${!i};
		fi
		CHECK_NETWORK=true;
		;;
	"-d")
		if $CHECK_DISK_USAGE; then
			duplicate_args_err ${!i};
		fi
		CHECK_DISK_USAGE=true;
		;;
	"-l")
		if $CHECK_LSERVICES; then
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
$CHECK_NIC && status_message="ON" ||  status_message="OFF";
echo "check_nic_health => $status_message";
$CHECK_DISK_USAGE && status_message="ON" || status_message="OFF";
echo "check_disk_usage => $status_message";
$CHECK_LSERVICES && status_message="ON" || status_message="OFF";
echo "check_lservices => $status_message";
$CHECK_NETWORK && status_message="ON" || status_message="OFF";
echo "check_NETWORK => $status_message";
echo;

# display listening services
if $CHECK_LSERVICES; then
	printf "PRINTING LISTENING SERVICES\n\n";

	result=$(lsof -i | grep -F LISTEN);
	if [[ -n "$result" ]]; then
		printf "%s\n\n" "$result"
	else
		printf "This machine does not appear to be running any services.\n\n"
	fi
fi
if $CHECK_NIC; then
	devices=$(ip link show | awk 'NR%2==1 { print $2 }' | tr -d :);
	for d in $devices; do
		result=$(ethtool "$d");
		printf "PRINTING INFORMATION FOR DEVICE: %s\n\n" "$d"
		printf "    %s\n\n" "$result"
	done
fi
if $CHECK_NETWORK; then
	printf "PRINTING NETWORK INFORMATION\n\n"
	ifconfig | xargs -0 printf "    %s\n\n"
fi
