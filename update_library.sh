#!/bin/sh

LIBURL=https://download.kiwix.org/library/library.xml

[ ! -x /usr/bin/xml2 ] && {
    echo "Error: xml2(1) not found. apt-get install xml2" >&2
    exit 1
}

rm -f library.xml library.xml.flat

wget -q $LIBURL

xml2 < library.xml | fgrep -v '/library/book/@favicon=' > library.xml.flat
