CREATE OR REPLACE VIEW public.cr3_nonproper_crashes_on_mainlane
AS WITH cr3_mainlanes AS (
         SELECT st_transform(st_buffer(st_transform(st_union(cr3_mainlanes.geometry), 2277), 1::double precision), 4326) AS geometry
           FROM public.cr3_mainlanes
        ), seek_direction AS (
         SELECT c_1.crash_id,
                CASE
                    WHEN "substring"(lower(c_1.rpt_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 'w'::text OR "substring"(lower(c_1.rpt_sec_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 'w'::text THEN 0
                    WHEN "substring"(lower(c_1.rpt_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 'n'::text OR "substring"(lower(c_1.rpt_sec_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 'n'::text THEN 90
                    WHEN "substring"(lower(c_1.rpt_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 'e'::text OR "substring"(lower(c_1.rpt_sec_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 'e'::text THEN 180
                    WHEN "substring"(lower(c_1.rpt_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 's'::text OR "substring"(lower(c_1.rpt_sec_street_name::text), '\s?([nsew])[arthous]*\s??b(oun)?d?'::text) ~* 's'::text THEN 270
                    ELSE NULL::integer
                END AS seek_direction
           FROM atd_txdot_crashes c_1
        )
 SELECT
    c.*,
        CASE
            WHEN c.rpt_street_name::text ~* '\s?([nsew])[arthous]*\s??b(oun)?d?'::text OR c.rpt_sec_street_name::text ~* '\s?([nsew])[arthous]*\s??b(oun)?d?'::text THEN true
            ELSE false
        END AS has_directionality,
    d.seek_direction,
    ( SELECT p.location_id
           FROM atd_txdot_locations p
          WHERE
                CASE
                    WHEN
                    CASE
                        WHEN (d.seek_direction - 65) < 0 THEN d.seek_direction - 65 + 360
                        ELSE d.seek_direction - 65
                    END < ((d.seek_direction + 65) % 360) THEN (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) >=
                    CASE
                        WHEN (d.seek_direction - 65) < 0 THEN d.seek_direction - 65 + 360
                        ELSE d.seek_direction - 65
                    END::double precision AND (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) <= ((d.seek_direction + 65) % 360)::double precision
                    ELSE (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) >=
                    CASE
                        WHEN (d.seek_direction - 65) < 0 THEN d.seek_direction - 65 + 360
                        ELSE d.seek_direction - 65
                    END::double precision OR (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) <= ((d.seek_direction + 65) % 360)::double precision
                END AND st_intersects(st_transform(st_buffer(st_transform(c."position", 2277), 750::double precision), 4326), p.shape) AND p.description ~~* '%SVRD%'::text
          ORDER BY (st_distance(st_centroid(p.shape), c."position"))
         LIMIT 1) AS surface_street_polygon,
    st_makeline(st_centroid(( SELECT p.shape
           FROM atd_txdot_locations p
          WHERE
                CASE
                    WHEN
                    CASE
                        WHEN (d.seek_direction - 65) < 0 THEN d.seek_direction - 65 + 360
                        ELSE d.seek_direction - 65
                    END < ((d.seek_direction + 65) % 360) THEN (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) >=
                    CASE
                        WHEN (d.seek_direction - 65) < 0 THEN d.seek_direction - 65 + 360
                        ELSE d.seek_direction - 65
                    END::double precision AND (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) <= ((d.seek_direction + 65) % 360)::double precision
                    ELSE (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) >=
                    CASE
                        WHEN (d.seek_direction - 65) < 0 THEN d.seek_direction - 65 + 360
                        ELSE d.seek_direction - 65
                    END::double precision OR (st_azimuth(c."position", st_centroid(p.shape)) * 180::double precision / pi()) <= ((d.seek_direction + 65) % 360)::double precision
                END AND st_intersects(st_transform(st_buffer(st_transform(c."position", 2277), 750::double precision), 4326), p.shape) AND p.description ~~* '%SVRD%'::text
          ORDER BY (st_distance(st_centroid(p.shape), c."position"))
         LIMIT 1)), c."position") AS visualization
   FROM atd_txdot_crashes c,
    cr3_mainlanes l,
    seek_direction d
     JOIN atd_jurisdictions aj ON aj.id = 5
  WHERE 1 = 1 AND d.crash_id = c.crash_id AND st_contains(aj.geometry, c."position") AND c.private_dr_fl::text = 'N'::text AND (c.rpt_road_part_id = ANY (ARRAY[2, 3, 4, 5, 7])) AND st_contains(l.geometry, c."position");

-- Ensure that this view is tracked in Hasura and that it has at least, surface_street_polygon & crash_id exposed for SELECT.
