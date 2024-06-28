DROP TRIGGER atd_txdot_location_audit_log on public.atd_txdot_locations;

DROP FUNCTION public.atd_txdot_locations_updates_audit_log();

CREATE FUNCTION public.atd_txdot_locations_updates_audit_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO atd_txdot_locations_change_log (location_id, record_json)
    VALUES (OLD.location_id, row_to_json(OLD));
    ------------------------------------------------------------------------------------------
    -- Street Name Standardization
    ------------------------------------------------------------------------------------------
    -- We have to make sure the intersection is organized alphabetically.
    -- The intersection description has to have this format:
    -- "11th @ Congress" (without the quotation marks)
    -- The script will automatically split the string by the '@' character
    -- and sort them into alphabetical order.
    IF (NEW.description IS NOT NULL) THEN
        NEW.description = (SELECT TRIM(STRING_AGG(TRIM(val), ' @ ')) AS output
                            FROM ( SELECT regexp_split_to_table(NEW.description, '@') AS val ORDER BY val ) AS sub);
    END IF;
    ------------------------------------------------------------------------------------------
    -- SCALE FACTOR
    ------------------------------------------------------------------------------------------
    -- If we have a scale factor, we assume it is in feet.
    -- The shape will be scaled up/down based on a positive or negative value in feet.
    -- The feet will then be converted to meters, which in turn is passed to the
    -- ST_Expand function, and the new shape is set based on the value it returns.
    IF(NEW.scale_factor IS NOT NULL AND NEW.shape IS NOT NULL) THEN
        NEW.shape = ST_Buffer(ST_SetSRID(NEW.shape,4326), (NEW.scale_factor/3.2808)*0.0000089);
    END IF;
    NEW.scale_factor = NULL; -- CLEAN UP FOR NEXT USE, REGARDLESS.
    --- END OF SCALE FACTOR OPERATIONS ---
    ------------------------------------------------------------------------------------------
    -- ST_CENTROID (latitude, longitude)
    ------------------------------------------------------------------------------------------
    -- If we have a shape, then calculate the centroid lat/longs
    IF(NEW.shape IS NOT NULL) THEN
        NEW.longitude = ST_X(ST_CENTROID(NEW.shape));
        NEW.latitude  = ST_Y(ST_CENTROID(NEW.shape));
    -- Else, default to NULL for lat/longs.
    ELSE
        NEW.longitude = NULL;
        NEW.latitude = NULL;
    END IF;
    --- END OF CENTROID OPERATIONS ---
    -- Record the current timestamp
    NEW.last_update = current_timestamp;
    RETURN NEW;
END;
$$;

create trigger atd_txdot_location_audit_log before
insert
    or
update
    on
    public.atd_txdot_locations for each row execute function atd_txdot_locations_updates_audit_log();
