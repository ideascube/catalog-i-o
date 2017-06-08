#!/bin/bash

function help()
{
echo "This script simply checks if all packages URL are correct, understand exists."
echo "Usage : $0 catalog.yml"
echo "You must give the name of the catalog you want to check."
echo "Example: $0 omeka.yml"
exit 1
}

[[ -z "$1" ]] && {
    help
    exit 1
}

[[ -x /usr/bin/HEAD ]] || {
    echo "Error: HEAD not found. apt-get install libwww-perl" >&2
    exit 2
}

URL_LIST=$( awk ' /url:/ { print $2 } ' $1  )

for i in $URL_LIST; do
	echo $i
	HEAD -t 3 -s -d $i 2>/dev/null
	case $? in
	 1)
		BADURL+=("$i")
		;;
	esac
done

if [[ ${#BADURL[@]} -ne 0 ]]; then
        echo "Missing URLs are : "
	for i in ${BADURL[@]}; do
		echo $i
	done
    exit 404
else
	echo "All URL are fine."
    exit 0
fi
