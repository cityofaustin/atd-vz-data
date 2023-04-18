-- This function inserts a new record into the fatality table
-- It is triggered by fatal insertions to the primaryperson or person tables
CREATE OR REPLACE FUNCTION fatality_insert() 
    RETURNS trigger
    LANGUAGE plpgsql
AS $function$
    BEGIN
    	IF (TG_TABLE_NAME = 'atd_txdot_primaryperson') THEN
    	    INSERT INTO fatalities (crash_id, primaryperson_id)
    		    VALUES (NEW.crash_id, NEW.primaryperson_id);
    	ELSIF (TG_TABLE_NAME = 'atd_txdot_person') THEN
    		INSERT INTO fatalities (crash_id, person_id)
    		    VALUES (NEW.crash_id, NEW.person_id);
    	END IF;
    	RETURN NEW;
    END
$function$
;
