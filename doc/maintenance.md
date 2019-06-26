# Catalog wizardry

Here are the casts to spell when it comes to edit a catalog.

## Setup your environment

```shell
git clone git@github.com:ideascube/catalog-i-o
```

## New item

Some types of content, such as [Kiwix](kiwix.md), require a special treatment.
Here is the generic workflow.

### Make a package

A package is a zip file with contents in it.

Pick a name, zip the files, host that somewhere:

```shell
zip mypackage.zip file.mp4 file.txt file.pdf
scp mypackage.zip server:/var/www/packages.ideascube.org/mypackage/
```

### Update the catalog

Get some metadata right out of your file:

```shell
ls -l mypackage.zip       # get the size
sha256sum mypackage.zip   # get the hash
```

Create a new item such as:

```yaml
  mypackage:
    description: "My handcrafted package"
    language: "fra"
    name: "My package"
    sha256sum: 37fb770fe8771463dba96c5e57caa8379e0125b7ac4f635b281c5903dd814bb7
    size: 2016932570
    type: zipped-medias
    url: http://packages.ideascube.org/mypackage/mypackage.zip
    version: '2016-12-24'
```

Upload the catalog:

```shell
upload_catalog.sh
```

Test your package instalation, then if everything works flawlessly, commit your changes:

```shell
git commit -a -m 'Add mypackage.'
git push
```

Profit.

## Item update

You usually only need to update the size, sha256sum and version fields.

Upload, commit, profit.
