-- First do the search: all street pairs within :distance Mercator meters which have same canonical name, but different name e.g. "Adama Mickiewicza", "Mickiewicza" - canonical name "mickiewicza"
\set distance 300
CREATE TEMPORARY TABLE unmatched_streets AS
SELECT
     a.osm_id AS id_a,
     a.name AS name_a,
     a.tags->'note' AS note_a,
     a.way AS way_a,
     b.osm_id AS id_b,
     b.name AS name_b,
     b.tags->'note' AS note_b,
     b.way AS way_b 
FROM
    planet_osm_line a,
    planet_osm_line b 
WHERE
    a.highway IS NOT NULL 
    AND b.highway IS NOT NULL 
    AND a.name IS NOT NULL 
    AND b.name IS NOT NULL 
    AND canonical_name(a.name) = canonical_name(b.name) 
    AND a.name != b.name 
    AND a.osm_id < b.osm_id 
    AND a.highway NOT IN
    ('bus_stop', 'platform')
    AND b.highway NOT IN
    ('bus_stop', 'platform')
    AND NOT a.tags ? 'public_transport'
    AND NOT b.tags ? 'public_transport'
    AND ST_DWithin(a.way, b.way, :distance);
-- Put found streets in one unified table so as to de-duplicate results    
CREATE TEMPORARY TABLE unmatched_streets_union AS
SELECT
    id_a AS osm_id,
    name_a AS name,
    note_a AS note,
    way_a AS way
FROM unmatched_streets
UNION
SELECT
    id_b AS osm_id,
    name_b AS name,
    note_b AS note,
    way_b AS way
FROM unmatched_streets;
-- Prepare HTML table which will be processed by sed and merged with header/footer
-- We use ST_ClusterDBSCAN(geom, eps, 1) to group nearby streets together due to its convenient semantics
-- as a window function instead of ST_ClusterWithin() which outputs an array of geometry collections (Yuck!)

-- Note also we don't use \o, as we want to capture row count e.g. (1234 rows) as well. The calling script
-- takes care to save the output.
\pset format html

SELECT
    array_to_string(array_sort_unique(array_agg(name)),E'\n') AS "Names",
    canonical_name(name) AS "Canonical name",
    'BEGINEDITLINKw' || string_agg(osm_id::text, ',w') || 'ENDEDITLINK' AS "Edit",
    array_to_string(array_sort_unique(array_agg(note)),E'\n') AS "Note" 
FROM
    ( SELECT
            osm_id,
            name,
            canonical_name(name),
            note,
            ST_ClusterDBSCAN(way, :distance, 1) OVER (PARTITION BY canonical_name(name)) AS cluster_no 
        FROM
            unmatched_streets_union 
    ) a 
GROUP BY
    canonical_name(name),
    cluster_no
ORDER BY
    canonical_name(name),    
    cluster_no \g mismatched_street_names_body.html

\t on
\pset format unaligned

SELECT jsonb_build_object(
    'type',     'FeatureCollection',
    'features', jsonb_agg(features.feature)
)
FROM (
  SELECT jsonb_build_object(
    'type',       'Feature',
    'geometry',   ST_AsGeoJSON(ST_Transform(way,4326),6)::jsonb,
    'properties', to_jsonb(inputs) - 'way'
  ) AS feature
  FROM (SELECT *, canonical_name(name) as canonical_name FROM unmatched_streets_union) inputs) features \g mismatched_street_names.geojson
