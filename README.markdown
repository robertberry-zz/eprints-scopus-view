# Eprints Scopus Screen plugin

Plug in for querying metadata from the Scopus API then selecting documents
from those returned for import.

Developed for the University of Liverpool Institutional Repository. GPL licensed.

## Dependencies

* [JSON Import plug in](https://github.com/robertberry/eprints-import-json)
* [Scopus Metadata Selector JavaScript](https://github.com/robertberry/scopus-metadata-selector)
  
## Setting up Scopus Metadata Selector JavaScript

* Follow the steps for building the JavaScript with your API key
* Rename `build/scripts/main.js` to `build/scripts/scopus_selector.js`
* Copy contents of `build/scripts` to your archive's JS folder (i.e. `cfg/static/javascript`)

## Installation

* Set up Scopus Metadata Selector JS (see above)
* Copy Scopus.pm to `cfg/plugins/EPrints/Plugin/Screen` (make the directories
  if they do not exist).
* Copy scopus_view.xml to `cfg/lang/en/phrases`.
* Restart Apache

e.g.

```bash

$ archive_root="/usr/share/eprints3/archives/test"
$ mkdir -p "$archive_root/cfg/plugins/EPrints/Plugin/Screen"
$ cp Scopus.pm "$archive_root/cfg/plugins/EPrints/Plugin/Screen"
$ mkdir -p "$archive_root/cfg/lang/en/phrases"
$ cp scopus_view "$archive_root/cfg/lang/en/phrases"
$ sudo apache2ctl restart

```
