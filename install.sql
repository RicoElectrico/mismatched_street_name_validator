create extension unaccent;
\i array_sort_unique.sql
\i canonical_name.sql
\echo Creating index...
CREATE INDEX planet_osm_line_canonical_name ON planet_osm_line USING btree (canonical_name(name)) WHERE ((highway IS NOT NULL) AND (name IS NOT NULL));
