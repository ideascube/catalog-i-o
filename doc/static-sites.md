# static-sites.yml

This catalog contains the metadata for the websites dump we used to ship with
our ideasboxes.

Example:

```yaml
      twentyfourhoursinanewsroom:
        name: 24h in a news room
        description: The foundations of journalism in four collections
        version: "2016-11-23"
        language: en
        url: http://packages.ideascube.org/24hinanewsroom/24hinanewsroom.en.zip
        size: 16072507
        sha256sum: 63fb63c86b89bc0f10d2ada6e0049853661bb95cbd8455400cbb245a2df1a864
        type: static-site
```

## `twentyfourhoursinanewsroom`

A key we made up.

Format: the only gotcha is, the package name will be used as a CSS class name in
ideascube, and CSS3 doesn't allow a class to start by a numeric. This entry is
an example of this gotcha.

Must not start by a number, only lower-case.

## `name`

A name we made up from the website name. Clever, huh?

## `description`

A description we made up from what we could. The website slogan, the first
sentence of the related Wikipedia entry, whatever.

## `version`

Following the `date` field from kiwix, it is the date the website was dumped.
