#!/bin/sh

[ ! -x /usr/bin/xml2 ] && {
    echo "Error: xml2(1) not found. apt-get install xml2" >&2
    exit 1
}

rm -f library.xml library.xml.flat

wget -q http://mirror3.kiwix.org/library/library.xml

xml2 < library.xml | fgrep -v '/library/book/@favicon=' > library.xml.flat
