-- How long is the trail?
SELECT st_length(st_union(geom)::geography) * 0.0006213712
FROM trail;

-- Who owns the most miles of trail?
SELECT ownername,
  st_length(st_union(geom)::geography) * 0.0006213712 AS miles
FROM trail
GROUP BY 1
HAVING st_length(st_union(geom)::geography) * 0.0006213712 > 10
ORDER BY 2 desc

-- How many roads does the trail cross?
SELECT COUNT(*) FROM pct_roads;

-- Which earthquakes happened within 1 mile of the trail?
-- Keep only roads segments that cross the PCT
DROP TABLE if EXISTS pct_earthquakes;
CREATE TABLE pct_earthquakes AS (
  SELECT earthquakes.*,
    to_char(TO_TIMESTAMP(time / 1000), 'YYYY-MM-DD') AS date,
  FROM earthquakes
  JOIN trail_simplified
  ON st_dwithin(trail_simplified.geom::geography,
                earthquakes.wkb_geometry::geography,
                1609, FALSE)
);

SELECT
  id,
  mag AS magnitude,
  place,
  to_char(TO_TIMESTAMP(time / 1000), 'YYYY-MM-DD') AS date,
  felt AS n_felt
FROM pct_earthquakes
ORDER BY mag desc
LIMIT 10;
