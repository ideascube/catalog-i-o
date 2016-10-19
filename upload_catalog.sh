#!/bin/sh

catalogs='kiwix.yml static-sites.yml'
remote='buildbot:/srv/catalog/'

htmlize() {
    local catalog=$1

    echo "<html>
    <head>
        <title>${catalog}</title>
        <meta charset='utf-8' />
    </head>
    <body>
        <pre>
$( cat $catalog )
        </pre>
    </body>
</html>" > ${catalog}.html

}


rm -f *.html

for i in $catalogs ; do
    htmlize $i
    scp $i ${i}.html $remote
    rm ${i}.html
done

