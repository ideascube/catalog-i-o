#!/bin/sh

html=kiwix.yml.html

rm -f $html

echo '<html>
    <head>
        <title>kiwix.yml</title>
        <meta charset="utf-8" />
    </head>
    <body>
        <pre>' > $html

cat kiwix.yml >> $html

echo '        </pre>
    </body>
</html>' >> $html

scp kiwix.yml $html buildbot:/srv/catalog/

rm -f $html
