#!/bin/bash
pkg_server="bubble.bsf-intranet.org"
omeka_pkg_dir="/var/www/packages.ideascube.org/omeka"

function help()
{
echo "This script allows 2 things :"
echo " - check if all packages URL are correct in a given catalog"
echo " - get a list of all packages thats are present on the package server, but missing from a catalog file."
echo
echo "Usage : $0 ACTION catalog.yml"
echo "Available actions :"
echo "	check_catalog"
echo "	list_unused"
echo 
echo "INFO : For now, this script only works for packages that are in omeka folder on remote server."
}

function get_unused_pkg()
{
	# Getting remote file list
	ssh $USER@$pkg_server "ls -l $omeka_pkg_dir/*.zip > pkg.list"
        scp $USER@$pkg_server:pkg.list .
        
	
	# Getting referenced urls from catalog
	url_list=$(grep url: $1 | awk '{print $2}')
	
	total_size=0
	cat pkg.list | while read pkg
	do
            pkg_name=$(echo $pkg | awk '{print $9}')
            pkg_size=$(echo $pkg | awk '{print $5}')
	    is_present=0

            for f in $url_list
	        do
	            # extracting filenames from urls
	            catalog_file_list=$(basename $f)
	            if [ $catalog_file_list == $pkg_name ]
	              then
	               is_present=1
	               break
	            fi
	        done
	    if [ $is_present -eq 0 ]
	     then
                  total_size=$((total_size + pkg_size))
                  size=$(echo $total_size | awk '{ foo = $1 / 1024 / 1024 / 1024 ; print foo "GB" }')
                  echo "Total bytes to save : $size"
	          echo "Detected unused package : $pkg_name"
	    fi
	done
}

function check_catalog_urls()
{
	[[ -x /usr/bin/HEAD ]] || {
	    echo "Error: HEAD not found. apt-get install libwww-perl" >&2
	    exit 2
	}
	
	 #Getting list of URL from catalog
	URL_LIST=$( awk ' /url:/ { print $2 } ' $1 | tr -d '"' | tr -d "'" )
	
	for i in $URL_LIST; do
		echo $i
		HEAD -H 'User-Agent: catalog-i-o/check-catalog-urls.sh' -t 3 -s -d $i 2>/dev/null
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
}

# less than 2 args provided
[[ -z "$2" ]] && {
    help
    exit 1
}

case $1 in
list_unused)
  get_unused_pkg $2
  ;;
check_catalog)
  check_catalog_urls $2
  ;;
*)
  help
  ;;
esac 
