CREATE FUNCTION public.find_service_road_location_for_centerline_crash(input_crash_id integer) RETURNS SETOF public.atd_txdot_locations
    LANGUAGE sql STABLE
    AS $$
with crash as (
  WITH cr3_mainlanes AS (
    SELECT st_transform(st_buffer(st_transform(st_union(cr3_mainlanes.geometry), 2277), 1), 4326) AS geometry
      FROM cr3_mainlanes
      )
  select c.crash_id, position,
    CASE
      WHEN "substring"(lower(c.rpt_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 'w' 
        OR "substring"(lower(c.rpt_sec_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 'w' THEN 0
      WHEN "substring"(lower(c.rpt_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 'n' 
        OR "substring"(lower(c.rpt_sec_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 'n' THEN 90
      WHEN "substring"(lower(c.rpt_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 'e' 
        OR "substring"(lower(c.rpt_sec_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 'e' THEN 180
      WHEN "substring"(lower(c.rpt_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 's' 
        OR "substring"(lower(c.rpt_sec_street_name), '\s?([nsew])[arthous]*\s??b(oun)?d?') ~* 's' THEN 270
      ELSE NULL
    END AS seek_direction
  from atd_txdot_crashes c
  join atd_jurisdictions aj on (aj.id = 5)
  join cr3_mainlanes on (ST_Contains(cr3_mainlanes.geometry, c.position))
  where 1 = 1
  and st_contains(aj.geometry, c.position) and c.private_dr_fl = 'N'
  and c.rpt_road_part_id = ANY (ARRAY[2, 3, 4, 5, 7])
  and c.crash_id = input_crash_id
  limit 1
)
select l.*
from atd_txdot_locations l
join crash c on (1 = 1)
where
CASE
  WHEN
  CASE
    WHEN (c.seek_direction - 65) < 0 THEN c.seek_direction - 65 + 360
    ELSE c.seek_direction - 65
  END < ((c.seek_direction + 65) % 360) THEN (st_azimuth(c.position, st_centroid(l.shape)) * 180 / pi()) >=
    CASE
      WHEN (c.seek_direction - 65) < 0 THEN c.seek_direction - 65 + 360
      ELSE c.seek_direction - 65
    END 
    AND (st_azimuth(c.position, st_centroid(l.shape)) * 180 / pi()) <= ((c.seek_direction + 65) % 360)
ELSE (st_azimuth(c.position, st_centroid(l.shape)) * 180 / pi()) >=
    CASE
      WHEN (c.seek_direction - 65) < 0 THEN c.seek_direction - 65 + 360
      ELSE c.seek_direction - 65
    END 
    OR (st_azimuth(c.position, st_centroid(l.shape)) * 180 / pi()) <= ((c.seek_direction + 65) % 360)
end
AND st_intersects(st_transform(st_buffer(st_transform(c.position, 2277), 750), 4326), l.shape) 
AND l.description ~~* '%SVRD%'
ORDER BY (st_distance(st_centroid(l.shape), c.position))
limit 1
$$;

CREATE FUNCTION public.find_noncr3_collisions_for_location(id character varying) RETURNS SETOF public.atd_apd_blueform
    LANGUAGE sql STABLE
    AS $$
SELECT
  *
FROM
  atd_apd_blueform AS blueform
WHERE
	ST_Contains((
		SELECT
  atd_loc.shape
FROM atd_txdot_locations AS atd_loc
WHERE
			atd_loc.location_id::VARCHAR=id), ST_SetSRID(ST_MakePoint (blueform.longitude, blueform.latitude), 4326))
$$;

CREATE FUNCTION public.find_cr3_collisions_for_location(id character varying) RETURNS SETOF public.atd_txdot_crashes
    LANGUAGE sql STABLE
    AS $$
SELECT
  *
FROM
  atd_txdot_crashes AS cr3_crash
WHERE
	ST_Contains((
		SELECT
  atd_loc.shape
FROM atd_txdot_locations AS atd_loc
WHERE
			atd_loc.location_id::VARCHAR=id), ST_SetSRID(ST_MakePoint(cr3_crash.longitude_primary, cr3_crash.latitude_primary), 4326))
$$;

CREATE FUNCTION public.search_atd_location_crashes(location_id character varying) RETURNS SETOF public.atd_txdot_crashes
    LANGUAGE sql STABLE
    AS $$
    SELECT atc.* FROM atd_txdot_crashes AS atc
    JOIN atd_txdot_locations AS atl ON ST_CONTAINS(atl.shape, atc.position)
    WHERE atl.unique_id = location_id;
$$;

CREATE FUNCTION public.search_atd_crash_location(crash_id integer) RETURNS SETOF public.atd_txdot_locations
    LANGUAGE sql STABLE
    AS $$
    SELECT * FROM atd_txdot_locations AS atl
    WHERE ST_Contains(atl.shape, (SELECT atc.position FROM atd_txdot_crashes AS atc WHERE atc.crash_id = crash_id))
$$;

CREATE FUNCTION public.search_atd_crash_locations(crash_id integer) RETURNS SETOF public.atd_txdot_locations
    LANGUAGE sql STABLE
    AS $$
    SELECT * FROM atd_txdot_locations AS atl
    WHERE ST_Contains(atl.shape, (SELECT atc.position FROM atd_txdot_crashes AS atc WHERE atc.crash_id = crash_id LIMIT 1))
    LIMIT 1
$$;
