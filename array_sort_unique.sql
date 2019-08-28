CREATE OR REPLACE FUNCTION array_sort_unique (ANYARRAY) RETURNS ANYARRAY
LANGUAGE SQL
AS $body$
  SELECT ARRAY(
    SELECT DISTINCT $1[s.i]
    FROM generate_series(array_lower($1,1), array_upper($1,1)) AS s(i)
    ORDER BY 1
  );
$body$;
