# Mismatched street names validator
<img src="https://raw.githubusercontent.com/RicoElectrico/mismatched_street_name_validator/master/screenshot.png" width="800">

This is a validator for OpenStreetMap street data. It searches for streets that have a similar, but not identical name and lie close to each other (e.g. 200 m).
For similarity purposes, punctuation, letter case, and optionally stop words (like given names or person titles) are removed.
For example:  
* "Adama Mickiewicza" and "Mickiewicza" ->  "mickiewicza"
* "Łąkowa" and "Łakowa" ->  "lakowa" (catching the missing diacritic)
* "Generała Tadeusza "Bora" Komorowskiego" and "Bora-Komorowskiego" -> "borakomorowskiego"
* "Große Wolfstraße" and "Große-Wolf-Straße" -> "grossewolfstrasse"

The tool exposes a link to edit all grouped street fragments in JOSM. Currently it's of no use for iD as it doesn't allow re-tagging of multiple objects at once.
Optionally you can browse a result on a map.

## Requirements
You need a PostGIS database with OSM data imported by `osm2pgsql`. Currently to fetch the `note` tag as well as to exclude bus stops we use `hstore` for compatibility with `openstreetmap-carto.style`, but this can be changed of course.

## Install
Assuming you have an OSM database `gis` with `hstore` and import style `openstreetmap-carto.style`, you need to install some functions,  `unaccent` extension and create an index.
You can customize the normalization function `canonical_name.sql`

```
psql -d gis -f install.sql
```

Then, customise your output directories, database name etc. in `analysis.sh`.
If you want to serve a map, copy `mismatched_street_names_map.html` and `style.json` to your output directory. Provide a Mapbox access token and customize map starting position.
## Usage

```
./analysis.sh
```
## Possible improvements
It's a very hacky tool using questionable techniques (like `sed` to generate JOSM edit links) but otherwise gets the job done.
* Substitute HTML output from psql with JSON, and load it via some JS library, enabling sorting of values
* For the map - replace Mapbox font stack with free one, so you don't need a Mapbox access token
