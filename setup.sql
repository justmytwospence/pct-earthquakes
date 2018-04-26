-- Convert trail projection from 3310 to lat/lon
ALTER TABLE trail
ALTER COLUMN geom TYPE geometry(MultiLineString, 4326)
USING st_transform(st_setSRID(geom, 3310), 4326);

-- Simplify the trail
DROP TABLE if EXISTS trail_simplified;
CREATE TABLE trail_simplified AS (
  SELECT
    st_simplify(st_union(geom), 0.001) AS geom,
    st_buffer(st_simplify(st_union(geom), 0.001)::geography, 1609) AS buffer
  FROM trail
);
CREATE INDEX trail_simplified_index ON trail_simplified USING GIST (geom);

-- Convert road projetions from 4269 to lat/lon
ALTER TABLE washington
ALTER COLUMN geom TYPE geometry(MultiLineString, 4326)
USING st_transform(st_setSRID(geom, 4269), 4326);
ALTER TABLE oregon
ALTER COLUMN geom TYPE geometry(MultiLineString, 4326)
USING st_transform(st_setSRID(geom, 4269), 4326);
ALTER TABLE california
ALTER COLUMN geom TYPE geometry(MultiLineString, 4326)
USING st_transform(st_setSRID(geom, 4269), 4326);

-- Combine roads into one relation
DROP TABLE IF EXISTS roads;
CREATE TABLE roads AS (
  SELECT * FROM washington
  UNION
  SELECT * FROM oregon
  UNION
  SELECT * FROM california
);
DROP TABLE if EXISTS california;
DROP TABLE if EXISTS washington;
DROP TABLE if EXISTS oregon;

-- Keep only roads segments that cross the PCT
DROP TABLE if EXISTS pct_roads;
CREATE TABLE pct_roads AS (
  SELECT roads.*
  FROM roads
  JOIN trail
  ON st_intersects(roads.geom, trail.geom)
);

-- -- diagnose problems in the shapefile
-- DROP TABLE if EXISTS woopsies;
-- CREATE TABLE woopsies AS (
--   WITH multiline_geoms AS (
--     SELECT *
--     FROM trail
--     WHERE st_numgeometries(geom) > 1)
--   SELECT trail.* FROM multiline_geoms
--   LEFT JOIN trail ON st_intersects(multiline_geoms.geom, trail.geom)
-- );
-- -- Find endpoints
-- DROP TABLE if EXISTS trail_endpoints;
-- CREATE TABLE trail_endpoints AS (
--   SELECT st_endpoint(st_linemerge(geom)) AS geom
--   FROM trail
--   UNION
--   SELECT st_startpoint(st_linemerge(geom)) AS geom
--   FROM trail
-- );
-- DROP TABLE if EXISTS trail_startpoints;
-- CREATE TABLE trail_startpoints AS (
--   SELECT st_startpoint(st_linemerge(geom)) AS geom
--   FROM trail
-- );
-- DROP TABLE if EXISTS trail_points;
-- CREATE TABLE trail_points AS (
--   SELECT *
--   FROM trail_startpoints
--   UNION
--   SELECT *
--   FROM trail_endpoints
-- );
