#!/bin/sh

rm -f library.xml library.xml.flat

wget -q http://mirror3.kiwix.org/library/library.xml

xml2 < library.xml | fgrep -v '/library/book/@favicon=' > library.xml.flat
