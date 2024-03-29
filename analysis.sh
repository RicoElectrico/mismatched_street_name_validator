#!/bin/bash

#Clean up old results
rm -f mismatched_street_names_body.html

# Generate report. Set your database name below if necessary.
psql -d gis4 -f  analysis.sql

# A very quick and dirty way to add JOSM edit links to HTML tables generated by psql.
sed -E -i  "s/(BEGINEDITLINK)([w,0-9]*)(ENDEDITLINK)/<a href=\"javascript:editObjects\(\'\2\'\)\">Edit<\/a>/" mismatched_street_names_body.html
echo "<br/>" >> mismatched_street_names_body.html

#Uncomment line below if you use Osmosis diff replication and want to include its timestamp (GMT time zone) in your report.
#grep timestamp /enter/your/path/to/state.txt >> mismatched_street_names_body.html

cat mismatched_street_names_header.html mismatched_street_names_body.html mismatched_street_names_footer.html > mismatched_street_names.html

# Set output directory below, remember to give write permissions to this directory to the current user
cp -f  mismatched_street_names.html /var/www/html/QA_map/testing/
cp -f mismatched_street_names.geojson /var/www/html/QA_map/testing/
