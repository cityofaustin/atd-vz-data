-- after populating VZ differences
-- calculate the difference between CRIS lat/lon and edits lat lon
WITH joined AS (
    SELECT
        cris.id,
        ST_SETSRID(ST_MAKEPOINT(
            cris.longitude,
            cris.latitude
        ),
        4326)::geography AS cris_pt,
        ST_SETSRID(ST_MAKEPOINT(
            edits.longitude,
            edits.latitude
        ),
        4326)::geography AS edits_pt
    FROM
        crashes_cris AS cris
    LEFT JOIN crashes_edits AS edits ON cris.id = edits.id
    WHERE
        cris.latitude IS NOT NULL
        AND cris.longitude IS NOT NULL
        AND edits.latitude IS NOT NULL
        AND edits.longitude IS NOT NULL
),

dists AS (
    SELECT
        id,
        ST_DISTANCE(
            cris_pt,
            edits_pt
        ) AS dist
    FROM
        joined
)

SELECT *
FROM
    dists
WHERE
    dist < 10;
