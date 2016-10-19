                  _        _
         ___ __ _| |_ __ _| | ___   __ _
        / __/ _` | __/ _` | |/ _ \ / _` |
       | (_| (_| | || (_| | | (_) | (_| |
        \___\__,_|\__\__,_|_|\___/ \__, |
                    .ideascube.org |___/

# CONTENT

* [kiwix.yml](kiwix.yml): latest version of ZIMs from Kiwix
* [kiwix.yml.html](kiwix.yml.html): the same content, readable from your web browser.
* [kiwix.yml](static-sites.yml): websites dumped and ZIM-packed
* [kiwix.yml.html](static-sites.yml.html): the same content, readable from your web browser.
* `update_library.sh`: downloads library.xml and gerenates a flat view from it (`library.xml.flat`).
* `upload_catalog.sh`: uploads the catalogs and browser-compliant versions as well.

# DISCLAIMER

Tried to automatize all of this. Was bitten by several exceptions.

Turns out I save some time by editing the catalog manually ; it is not error-proof,
but still faster than fighting with exceptions within the shell scripts.

Below are some notes taken before I turned that pragmatic.


# (CURRENT) UPDATE PROCESS

"Agile"/"Rache" process. Details on the BSF wiki. In a nutshell:

    $ ./update_library.sh
    $ vi kiwix.yml                  # open the catalog
    :read kiwix.yml.sample          # append a skeleton
    $ view library.xml.flat         # copy some of the values from here
    $ view ${ZIPPED_ZIM_URL}.meta4  # copy `size` and `sha256sum` from here
    $ git commit -a -m 'Add something.lang'
    $ ./upload_catalog.sh           # upload the catalog and generate an HTML view as well


# (OLD) NOTES

## EXPECTED RESULT

For a single ZIM:

    wikipedia.en:
      name: "Wikipedia -- From Wikipedia, the free encyclopedia"
      version: "2016-03-01"
      url: "http://download.kiwix.org/portable/wikipedia/kiwix-0.9+wikipedia_en_all_2016-02.zip"
      sha256sum: "41b65c433826ff0564de952d0df41a16f780df57c5957ecbfdf06f8b77e1f45b"
      size: "68042250908"
      type: zipped-zim
      handler: kiwix

Data sources:

    Key             Source                                  Misc
    wikipedia.en    built from filename
    name            built from $title + $description
    version         $date from library.xml                  see also $published & $mtime from .meta4 files
    url             built from $origin from .zip.meta4
    sha256sum       from .zip.meta4
    size            from .zip.meta4
    type            static/diy
    handler         static/diy

Other fields that can be used:

    language: "eng"                                     (from library.xml)  (3+ letters, needs to be mapped)
    description: "From Wikipedia, the free encyclopedia" (from library.xml) (may contains weird characters)
    title: "Wikipedia"                                  (from library.xml)  (may contains weird characters)
    id: "1958db66-ef5d-49c9-3946-487451fee7dd"          (from library.xml)  (nice one, bro)
    filename: kiwix-0.9+wikistage_fr_all_2015-07.zip    (from .zip.meta4)
    published: 2016-03-09T15:38:18Z                     (from .zip.meta4)
    mtime: 1436874383                                   (from .zip.meta4, XML comment)


## URLs

Multiple URLs per ZIM :

* http://download.kiwix.org/portable/other/kiwix-0.9+wikistage_fr_all_2015-07.zip
* http://download.kiwix.org/portable/other/kiwix-0.9+wikistage_fr_all_2015-07.zip.meta4
* http://download.kiwix.org/zim/other/wikistage_fr_all_2015-07.zim
* http://download.kiwix.org/zim/other/wikistage_fr_all_2015-07.zim.meta4


## catalog.yml

Example:

      wikipedia.en:
        version: "2016-03-01"
        size: "68042250908"
        url: "http://download.kiwix.org/portable/wikipedia/kiwix-0.9+wikipedia_en_all_2016-02.zip"
        name: "Wikipedia -- From Wikipedia, the free encyclopedia"
        language: "eng"
        description: "From Wikipedia, the free encyclopedia"
        id: "1958db66-ef5d-49c9-3946-487451fee7dd"
        title: "Wikipedia"
        sha256sum: "41b65c433826ff0564de952d0df41a16f780df57c5957ecbfdf06f8b77e1f45b"
        langid: "wikipedia.en"
        type: zipped-zim
        handler: kiwix

Data sources:

      wikipedia.en: == $langid
        version: library.xml
        size: .zip.meta4
        url: library.xml
        name: library.xml ($title -- $description)
        language: library.xml
        description: library.xml
        id: library.xml
        title: library.xml
        sha256sum: .zip.meta4
        langid: Hand crafted
        type: Hand crafted
        handler: Hand crafted

## GOTCHAS

> In programming, a gotcha is a valid construct in a system, program or programming language that works as documented but is counter-intuitive and almost invites mistakes because it is both easy to invoke and unexpected or unreasonable in its outcome.
> <https://en.wikipedia.org/wiki/Gotcha_%28programming%29>

### Kiwix gotchas

Inconsistent file naming. Expect project_lang_type_date? Deal with that:

    ubuntudoc_fr_2009-01
    ubuntudoc_fr_all_2015-02
    ted_en_global_issues_2015-02
    wikipedia_en_ray_charles_2015-06

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

