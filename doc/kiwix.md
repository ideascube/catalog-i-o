# Kiwix catalog

The kiwix.yml catalog stores entries from Kiwix.org.

It doesn't contains all of the Kiwix ZIMs, only the ones BSF needed to ship.

## DISCLAIMER

Early days. Tried to automatize all of this. Was bitten by several exceptions.

Turned out we save some time by editing the catalog manually ; it is not
error-proof, but still faster than fighting with exceptions within the shell
scripts. Seee the [Gotchas](#gotchas) section below.

At some point, Kiwix stopped publishing zipped-zim files and turned to plain
ZIM files (which now include the file index). As a result, the `library.xml`
doesn't exist anymore, and several fields had to be built manually.

Later on, Kiwix implemented an automated workflow, and published several API endpoints.

As a result, all of this could be completely automated - see [issue #20](https://github.com/ideascube/catalog-i-o/issues/20).

## (current) update process

"Agile"/"Rache" process. Details on the BSF wiki. In a nutshell:

```text
$ ./update_library.sh
$ vi kiwix.yml                  # open the catalog
:read kiwix.yml.sample          # append a skeleton
<keyboard stokes>               # `name` & `description` from ZimFarm Recipe
<keyboard strokes>              # `lang` from ZimFarm Recipe
$ view ${ZIPPED_ZIM_URL}.meta4  # copy `size` and `sha256sum` from here
$ git commit -a -m 'Add something.lang'
$ ./upload_catalog.sh           # upload the catalog and generate an HTML view as well
```

## Sources of information

Multiple URLs per ZIM :

* <http://download.kiwix.org/zim/other/wikistage_multi_all_2020-07.zim>
* <http://download.kiwix.org/zim/other/wikistage_multi_all_2020-07.zim.meta4>

ZimFarm Config:
* <https://farm.openzim.org/recipes/wikistage_mul_all>
* <https://farm.openzim.org/recipes/wikistage_mul_all/config>

ZimFarm Schedule API:
* <https://api.farm.openzim.org/v1/schedules/wikistage_mul_all>

## Fields

Some of the values can be taken from the `.meta4` file that goes with any ZIM file.

Example:

```yaml
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
```

### `wikiquote.fr`

A key we make up out of the filename.

Format : `name` + `.` + `lang`. Must not start by a number, only lower-case.

### `name`

Used to be taken from `library.xml`:`name` field.

Taken from the `title` field from the ZimFarm Recipe Config. Beware: ZimFarm uses `name` for something else!

### `description`

Used to be taken from `library.xml`:`name` field.

Taken from the `description` field from the ZimFarm Recipe Config.

### `version`

Used to be taken from `library.xml`:`version`.

Use the date as shown at `download.kiwix.org`. Alternatively, this can be build from the ZimFarm Schedule API, field `.most_recent_task.updated_at`. Example:

```shell
curl --silent https://api.farm.openzim.org/v1/schedules/nota_bene | jq -r .most_recent_task.updated_at

```

### `language`

Used to be taken from `library.xml`:`lang`. It happened that it's not accurate.
Example: Bil Tunisia is supposed to be in arabic but most of the talks are
actually in french.

Copy from the `language` field from the ZimFarm Recipe Config.

### `id`

Used to be taken from `library.xml`:`id`. Not used by ideascube, we were copying
it expecting we would find an use for it someday. Now `library.xml` is gone,
these `id` fields have been removed.

### `url`

Used to be taken from `library.xml`:`url`.

Just copy the link from the [download page](http://download.kiwix.org/zim/).

Alternatively, this could be built from the ZimFarm Schedule API:

```shell
$ curl --silent https://api.farm.openzim.org/v1/schedules/micmaths | jq -r '"http://download.kiwix.org/zim/" + .category + "/" + .config.flags.name + "_" + ( .most_recent_task.updated_at | split("-")[0:2] | join("-")) + ".zim"
http://download.kiwix.org/zim/other/micmaths_fr_all_2020-03.zim
```

### `size`

Taken from `url`.meta4, or from `ls -l`.

### `sha256sum`

Taken from `url`.meta4 or from the `sha256sum(1)` command output.

### `type`

For ZIMs from Kiwix.org, it must be `zim`.

Kiwix doesn't build `zipped-zim` files anymore.

### The .meta4 file

meta4 files embbed several informations that are useful to us.

To get it, just add `.meta4` to the end of the `url`.
Example:
<http://download.kiwix.org/portable/wikiquote/kiwix-0.9+wikiquote_fr_all_2016-11.zim.meta4>

## Gotchas

> In programming, a gotcha is a valid construct in a system, program or
programming language that works as documented but is counter-intuitive and
almost invites mistakes because it is both easy to invoke and unexpected or
unreasonable in its outcome.
> <https://en.wikipedia.org/wiki/Gotcha_%28programming%29>

Note: all these gotchas were written before Kiwix implemented some APIs and automated workflows. These API often provide workarounds.

Note: middle 2022, a [Naming Convention](https://github.com/openzim/overview/wiki/Naming-Convention) was born! Everything bellow belongs to the past.

Inconsistent file naming. Expect project_lang_type_date? Deal with that:

```text
ubuntudoc_fr_2009-01
ubuntudoc_fr_all_2015-02
ted_en_global_issues_2015-02
wikipedia_en_ray_charles_2015-06
```

And consider this one:

```shell
$ rsync --recursive --list-only \
  download.kiwix.org::download.kiwix.org/portable/ \
    | grep ".zip" | grep -F -v '_nopic_' \
      | tr -s ' ' | cut -d ' ' -f5 | sort -r \
        | sed 's/_20[0-9][0-9]-[0-9][0-9]\.zip//g' | fgrep _20
wikipedia/kiwix-0.9+wikipedia_en_uganda_09_2014.zip
gutenberg/kiwix-0.9+gutenberg_pt_all_10_2014.zip
gutenberg/kiwix-0.9+gutenberg_it_all_10_2014.zip
gutenberg/kiwix-0.9+gutenberg_fr_all_10_2014.zip
gutenberg/kiwix-0.9+gutenberg_fr_all_09_2014.zip
gutenberg/kiwix-0.9+gutenberg_es_all_10_2014.zip
gutenberg/kiwix-0.9+gutenberg_en_all_10_2014.zip
gutenberg/kiwix-0.9+gutenberg_de_all_10_2014.zip
```

Incomplete entries / missing fields. Flattening ubuntudoc.fr from library.xml:

```text
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
```

Language mapping: we want ISO 639-1 (two letters).
`library.xml` has language as ISO 639-2 code (3 letters), but sometimes it's
more than three letters, sometimes it's multiple languages. List of exceptions
(not 3 letters long):

```text
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
```
