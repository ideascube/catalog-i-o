# Kiwix catalog

The kiwix.yml catalog stores entries from Kiwix.org.

It doesn't contains all of the Kiwix ZIMs, only the ones BSF needed to ship.


## DISCLAIMER

Tried to automatize all of this. Was bitten by several exceptions.

Turns out we save some time by editing the catalog manually ; it is not
error-proof, but still faster than fighting with exceptions within the shell
scripts. Seee the [Gotchas](#gotchas) section below.


## (current) update process

"Agile"/"Rache" process. Details on the BSF wiki. In a nutshell:

    $ ./update_library.sh
    $ vi kiwix.yml                  # open the catalog
    :read kiwix.yml.sample          # append a skeleton
    $ view library.xml.flat         # copy some of the values from here
    $ view ${ZIPPED_ZIM_URL}.meta4  # copy `size` and `sha256sum` from here
    $ git commit -a -m 'Add something.lang'
    $ ./upload_catalog.sh           # upload the catalog and generate an HTML view as well


## library.xml

This file is available from kiwix.org and contains the whole Kiwix collection.
It is easier to get metadatas from this file than browsing the Kiwix website.
However, XML can be hard to read, so it is flattened using `xml2(1)`.

The `update_library.sh` script takes care of that: it downloads the latest
`library.xml` file, then flattenis it to `library.xml.flat`. It also removes
the favicon which we don't need.


## Fields

Most of the values can be taken from Kiwix library.xml entries. However, some
names and descriptions are poorly written, some fields can be missing from the
`.xml` file. See the [gotchas](gotchas) section below.

Example:

      wikiquote.fr:
        name: "Wikiquote"
        description: "La collection libre de citations"
        version: "2016-11-15"
        language: "fra"
        id: "8d3aafd9-dd6b-4c91-99a1-8c341a4a6e71"
        url: "http://download.kiwix.org/portable/wikiquote/kiwix-0.9+wikiquote_fr_all_2016-11.zip"
        size: 246253671
        sha256sum: "74eedc858d8fc4ae444d535e7746b0bff4870493fbe8ece49f603223c27f8a9e"
        type: zipped-zim

### `wikiquote.fr`

A key we make up out of the filename.

Format : `name` + `.` + `lang`. Must not start by a number, only lower-case.

### `name`

Taken from `library.xml`:`name` field, but sometimes has to be rewritten.

### `description`

Taken from `library.xml`:`description`, but most of the times has to be
rewritten.

### `version`

Taken from `library.xml`:`version`.

### `language`

Taken from `library.xml`:`lang`.

It can happen that it's not accurate. Example: Bil Tunisia is supposed to be in
arabic but most of the talks are actually in french.

### `id`

Taken from `library.xml`:`id`. Not used by ideascube, but maybe some day...
ideascube will silently ignore this field.

### `url`

Taken from `library.xml`:`url`.

### `size`

Taken from `url`.meta4, or from `ls -l`.

### `sha256sum`

Taken from `url`.meta4 or from the `sha256sum(1)` command output.

### `type`

For ZIMs from Kiwix.org, it must be `zipped-zim`.


### The .meta4 file

meta4 files embbed several informations that are useful to us.

To get it, just add `.meta4` to the end of the `url`. Example:
http://download.kiwix.org/portable/wikiquote/kiwix-0.9+wikiquote_fr_all_2016-11.zip.meta4


## URLs

Multiple URLs per ZIM :

* http://download.kiwix.org/portable/other/kiwix-0.9+wikistage_fr_all_2015-07.zip
* http://download.kiwix.org/portable/other/kiwix-0.9+wikistage_fr_all_2015-07.zip.meta4
* http://download.kiwix.org/zim/other/wikistage_fr_all_2015-07.zim
* http://download.kiwix.org/zim/other/wikistage_fr_all_2015-07.zim.meta4


## Gotchas

> In programming, a gotcha is a valid construct in a system, program or programming language that works as documented but is counter-intuitive and almost invites mistakes because it is both easy to invoke and unexpected or unreasonable in its outcome.
> <https://en.wikipedia.org/wiki/Gotcha_%28programming%29>


Inconsistent file naming. Expect project_lang_type_date? Deal with that:

    ubuntudoc_fr_2009-01
    ubuntudoc_fr_all_2015-02
    ted_en_global_issues_2015-02
    wikipedia_en_ray_charles_2015-06

And consider this one:

    $ rsync --recursive --list-only download.kiwix.org::download.kiwix.org/portable/ \
      | grep ".zip" | grep -F -v '_nopic_' | tr -s ' ' | cut -d ' ' -f5 | sort -r \
        | sed 's/_20[0-9][0-9]-[0-9][0-9]\.zip//g' | fgrep _20
    wikipedia/kiwix-0.9+wikipedia_en_uganda_09_2014.zip
    gutenberg/kiwix-0.9+gutenberg_pt_all_10_2014.zip
    gutenberg/kiwix-0.9+gutenberg_it_all_10_2014.zip
    gutenberg/kiwix-0.9+gutenberg_fr_all_10_2014.zip
    gutenberg/kiwix-0.9+gutenberg_fr_all_09_2014.zip
    gutenberg/kiwix-0.9+gutenberg_es_all_10_2014.zip
    gutenberg/kiwix-0.9+gutenberg_en_all_10_2014.zip
    gutenberg/kiwix-0.9+gutenberg_de_all_10_2014.zip

Incomplete entries / missing fields. Flattening ubuntudoc.fr from library.xml:

    /library/book
    /library/book/@id=e04bcf41-eae8-b04b-da2d-0c00f4220000
    /library/book/@title=ubuntudoc fr 2009-01
    /library/book/@url=http://download.kiwix.org/zim/other/ubuntudoc_fr_2009-01.zim.meta4
    /library/book/@articleCount=4124
    /library/book/@mediaCount=3740
    /library/book/@size=278580
     
    /library/book
    /library/book/@id=4beabd8a-c7b8-a97f-2a0a-1889b586ddc8
    /library/book/@title=Documentation Ubuntu Française
    /library/book/@description=Version hors ligne du wiki: doc.ubuntu-fr.org
    /library/book/@language=fra
    /library/book/@creator=doc.ubuntu-fr.org
    /library/book/@publisher=Darkjam
    /library/book/@date=2015-12-15
    /library/book/@url=http://download.kiwix.org/zim/other/ubuntudoc_fr_all_2015-12.zim.meta4
    /library/book/@articleCount=10284
    /library/book/@mediaCount=5244
    /library/book/@size=478531

Language mapping: we want ISO 639-1 (two letters).
`library.xml` has language as ISO 639-2 code (3 letters), but sometimes it's more than three letters, sometimes it's multiple languages. List of exceptions (not 3 letters long):

    be-tarask
    cbk-zam
    crh-latn
    de
    en
    map-bms
    nds-nl
    per,eng
    roa-tara
    sh
    zh-min-nan

