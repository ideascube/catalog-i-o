#!/bin/sh

catalogs='kiwix.yml static-sites.yml bibliotecamovil.yml bukavu.yml omeka.yml'
remote='bubble:/var/www/catalog.ideascube.org/'

htmlize() {
    local catalog=$1

    echo "<html>
    <head>
        <title>${catalog}</title>
        <meta charset='utf-8' />
    </head>
    <body>
        <pre>
$( cat "$catalog" )
        </pre>
    </body>
</html>" > "${catalog}.html"

}


rm -f ./*.html

for i in $catalogs ; do
    htmlize "$i"
    scp "$i" "${i}.html" $remote
    rm "${i}.html"
done

pandoc -f markdown -t html README.md > README.html
scp README.html $remote
