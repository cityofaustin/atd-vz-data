-- Updating the update_noncr3_location function to use geometry instead of shape
DROP TRIGGER update_noncr3_location_on_insert ON atd_apd_blueform;

DROP TRIGGER update_noncr3_location_on_update ON atd_apd_blueform;

DROP FUNCTION public.update_noncr3_location();

CREATE OR REPLACE FUNCTION public.update_noncr3_location()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
	-- Check if crash is on a major road and of concern to TxDOT.
	-- NEW.position is recalculated in a trigger called
	-- atd_txdot_blueform_update_position which runs before this trigger.
	IF EXISTS (
		SELECT
			ncr3m.*
		FROM
			non_cr3_mainlanes AS ncr3m
		WHERE ((NEW.position && ncr3m.geometry)
			AND ST_Contains(ST_Transform(ST_Buffer(ST_Transform(ncr3m.geometry, 2277), 1, 'endcap=flat join=round'), 4326),
				/* transform into 2277 to buffer by a foot, not a degree */
				NEW.position))) THEN
	-- If it is, then set the location_id to None
	NEW.location_id = NULL;
ELSE
	-- If it isn't on a major road and is of concern to Vision Zero, try to find a location_id for it.
	NEW.location_id = (
		SELECT
			location_id
		FROM
			atd_txdot_locations AS atl
		WHERE (atl.location_group = 1
			AND(atl.geometry && NEW.position)
			AND ST_Contains(atl.geometry, NEW.position)));
END IF;
	RETURN NEW;
END;
$function$
;

create trigger update_noncr3_location_on_insert before
insert
    on
    public.atd_apd_blueform for each row
    when (((new.latitude is not null)
        and (new.longitude is not null))) execute function update_noncr3_location();
        
create trigger update_noncr3_location_on_update before
update
    on
    public.atd_apd_blueform for each row
    when (((old.latitude is distinct
from
    new.latitude)
    or (old.longitude is distinct
from
    new.longitude))) execute function update_noncr3_location();