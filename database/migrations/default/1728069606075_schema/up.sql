--
-- PostgreSQL database dump
--

-- Dumped from database version 14.7 (Debian 14.7-1.pgdg110+1)
-- Dumped by pg_dump version 14.7 (Debian 14.7-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
-- SELECT pg_catalog.set_config('search_path', '', false); // this has to be disabled to make certain equality operators work with geometry typed columns
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: lookups; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA lookups;


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: afd_incidents_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.afd_incidents_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  update afd__incidents set
    austin_full_purpose = (
      select ST_Contains(jurisdiction.geometry, incidents.geometry)
      from afd__incidents incidents
      left join atd_jurisdictions jurisdiction on (jurisdiction.jurisdiction_label = 'AUSTIN FULL PURPOSE')
      where incidents.id = new.id),
    location_id = (
      select locations.location_id
      from afd__incidents incidents
      join atd_txdot_locations locations on (
        true
        and locations.location_group = 1 -- this was added to rule out old level 5s
        and incidents.geometry && locations.geometry
        and ST_Contains(locations.geometry, incidents.geometry)
      )
      where incidents.id = new.id),
    latitude = ST_Y(afd__incidents.geometry),
    longitude = ST_X(afd__incidents.geometry),
    ems_incident_number_1 = afd__incidents.ems_incident_numbers[1],
    ems_incident_number_2 = afd__incidents.ems_incident_numbers[2],
    call_date = date(afd__incidents.call_datetime),
    call_time = afd__incidents.call_datetime::time
    where afd__incidents.id = new.id;
RETURN NEW;
END;
$$;


--
-- Name: atd_txdot_blueform_update_position(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.atd_txdot_blueform_update_position() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

BEGIN

   NEW.position = ST_SetSRID(ST_Point(NEW.longitude, NEW.latitude), 4326);

   RETURN NEW;

END;

$$;


--
-- Name: build_crash_address(text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.build_crash_address(block_num text, street_pfx text, street_name text, street_sfx text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    address text := '';
BEGIN
    -- Concat each address part only if it's not null and not an empty string
    IF block_num IS NOT NULL AND block_num <> '' THEN
        address := block_num || ' ';
    END IF;
    
    IF street_pfx IS NOT NULL AND street_pfx <> '' THEN
        address := address || street_pfx || ' ';
    END IF;
    
    IF street_name IS NOT NULL AND street_name <> '' THEN
        address := address || street_name || ' ';
    END IF;
    
    IF street_sfx IS NOT NULL AND street_sfx <> '' THEN
        address := address || street_sfx || ' ';
    END IF;
    
    -- Trim the final address to remove any trailing space
    address := trim(address);

    -- Return NULL if the trimmed address is empty
     IF address = '' THEN
        RETURN NULL;
    ELSE
        RETURN address;
    END IF;

END;
$$;


--
-- Name: charges_cris_set_person_id_and_crash_pk(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.charges_cris_set_person_id_and_crash_pk() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   person_record record;
begin
    select into person_record people_cris.id as person_id, units.crash_pk as crash_pk
        from public.people_cris
        left join public.units on public.units.id = people_cris.unit_id
        where
            people_cris.cris_crash_id = new.cris_crash_id
            and people_cris.unit_nbr = new.unit_nbr
            and people_cris.prsn_nbr = new.prsn_nbr;
    new.person_id = person_record.person_id;
    new.crash_pk = person_record.crash_pk;
    RETURN new;
END;
$$;


--
-- Name: crashes_cris_insert_rows(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crashes_cris_insert_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.crashes (
        active_school_zone_fl,
        at_intrsct_fl,
        case_id,
        cr3_processed_at,
        cr3_stored_fl,
        crash_speed_limit,
        crash_timestamp,
        created_by,
        cris_crash_id,
        fhe_collsn_id,
        id,
        intrsct_relat_id,
        investigat_agency_id,
        investigator_narrative,
        is_deleted,
        is_temp_record,
        latitude,
        light_cond_id,
        longitude,
        medical_advisory_fl,
        obj_struck_id,
        onsys_fl,
        private_dr_fl,
        road_constr_zone_fl,
        road_constr_zone_wrkr_fl,
        rpt_block_num,
        rpt_city_id,
        rpt_cris_cnty_id,
        rpt_hwy_num,
        rpt_hwy_sfx,
        rpt_rdwy_sys_id,
        rpt_ref_mark_dir,
        rpt_ref_mark_dist_uom,
        rpt_ref_mark_nbr,
        rpt_ref_mark_offset_amt,
        rpt_road_part_id,
        rpt_sec_block_num,
        rpt_sec_hwy_num,
        rpt_sec_hwy_sfx,
        rpt_sec_rdwy_sys_id,
        rpt_sec_road_part_id,
        rpt_sec_street_desc,
        rpt_sec_street_name,
        rpt_sec_street_pfx,
        rpt_sec_street_sfx,
        rpt_street_desc,
        rpt_street_name,
        rpt_street_pfx,
        rpt_street_sfx,
        rr_relat_fl,
        schl_bus_fl,
        surf_cond_id,
        surf_type_id,
        thousand_damage_fl,
        toll_road_fl,
        traffic_cntl_id,
        txdot_rptable_fl,
        updated_by,
        wthr_cond_id
    ) values (
        new.active_school_zone_fl,
        new.at_intrsct_fl,
        new.case_id,
        new.cr3_processed_at,
        new.cr3_stored_fl,
        new.crash_speed_limit,
        new.crash_timestamp,
        new.created_by,
        new.cris_crash_id,
        new.fhe_collsn_id,
        new.id,
        new.intrsct_relat_id,
        new.investigat_agency_id,
        new.investigator_narrative,
        new.is_deleted,
        new.is_temp_record,
        new.latitude,
        new.light_cond_id,
        new.longitude,
        new.medical_advisory_fl,
        new.obj_struck_id,
        new.onsys_fl,
        new.private_dr_fl,
        new.road_constr_zone_fl,
        new.road_constr_zone_wrkr_fl,
        new.rpt_block_num,
        new.rpt_city_id,
        new.rpt_cris_cnty_id,
        new.rpt_hwy_num,
        new.rpt_hwy_sfx,
        new.rpt_rdwy_sys_id,
        new.rpt_ref_mark_dir,
        new.rpt_ref_mark_dist_uom,
        new.rpt_ref_mark_nbr,
        new.rpt_ref_mark_offset_amt,
        new.rpt_road_part_id,
        new.rpt_sec_block_num,
        new.rpt_sec_hwy_num,
        new.rpt_sec_hwy_sfx,
        new.rpt_sec_rdwy_sys_id,
        new.rpt_sec_road_part_id,
        new.rpt_sec_street_desc,
        new.rpt_sec_street_name,
        new.rpt_sec_street_pfx,
        new.rpt_sec_street_sfx,
        new.rpt_street_desc,
        new.rpt_street_name,
        new.rpt_street_pfx,
        new.rpt_street_sfx,
        new.rr_relat_fl,
        new.schl_bus_fl,
        new.surf_cond_id,
        new.surf_type_id,
        new.thousand_damage_fl,
        new.toll_road_fl,
        new.traffic_cntl_id,
        new.txdot_rptable_fl,
        new.updated_by,
        new.wthr_cond_id
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.crashes_edits (id) values (new.id);

    RETURN NULL;
END;
$$;


--
-- Name: crashes_cris_set_old_investigator_narrative(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crashes_cris_set_old_investigator_narrative() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.investigator_narrative = old.investigator_narrative;
    return new;
end;
$$;


--
-- Name: FUNCTION crashes_cris_set_old_investigator_narrative(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.crashes_cris_set_old_investigator_narrative() IS 'Sets the
investigator_narrative to its previous value if the updated value is null. This 
trigger function addresses a known CRIS bug in which updated crash records are 
missing the invesitgator narrative. It is tracked via DTS issue 
https://github.com/cityofaustin/atd-data-tech/issues/18971 and CRIS ticket #854366';


--
-- Name: crashes_cris_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crashes_cris_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
    new_cris_jb jsonb := to_jsonb (new);
    old_cris_jb jsonb := to_jsonb (old);
    edit_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.crashes set ';
begin
    -- get corresponding the VZ record as jsonb
    SELECT to_jsonb(crashes_edits) INTO edit_record_jb from public.crashes_edits where public.crashes_edits.id = new.id;

    -- for every key in the cris json object
    for column_name in select jsonb_object_keys(new_cris_jb) loop
        -- ignore audit fields
        continue when column_name in ('created_at', 'updated_at', 'created_by', 'updated_by');
        -- if the new value doesn't match the old
        if(new_cris_jb -> column_name <> old_cris_jb -> column_name) then
            -- see if the vz record has a value for this field
            if (edit_record_jb ->> column_name is  null) then
                -- this value is not overridden by VZ
                -- so update the unified record with this new value
                updates_todo := updates_todo || format('%I = $1.%I', column_name, column_name);
            end if;
        end if;
    end loop;
    if(array_length(updates_todo, 1) > 0) then
        -- set audit field updated_by to match cris record
        updates_todo := updates_todo || format('%I = $1.%I', 'updated_by', 'updated_by');
        -- complete the update statement by joining all `set` clauses together
        update_stmt := update_stmt
            || array_to_string(updates_todo, ',')
            || format(' where public.crashes.id = %s', new.id);
        raise debug 'Updating crashes record from CRIS update';
        execute (update_stmt) using new;
    else
        raise debug 'No changes to unified record needed';
    end if;
    return null;
end;
$_$;


--
-- Name: crashes_edits_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crashes_edits_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
    new_edits_jb jsonb := to_jsonb (new);
    cris_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.crashes set ';
begin
    -- get corresponding the cris record as jsonb
    SELECT to_jsonb(crashes_cris) INTO cris_record_jb from public.crashes_cris where public.crashes_cris.id = new.id;
    -- for every key in the vz json object
    for column_name in select jsonb_object_keys(new_edits_jb) loop
        -- ignore audit fields, except updated_by
        continue when column_name in ('created_at', 'updated_at', 'created_by');
        --  create a set statement for the column
        if cris_record_jb ? column_name then
            -- if this column exists on the cris table, coalesce vz + cris values
            updates_todo := updates_todo
            || format('%I = coalesce($1.%I, cris_record.%I)', column_name, column_name, column_name);
        else
            updates_todo := updates_todo
            || format('%I = $1.%I', column_name, column_name);
        end if;
    end loop;
    -- join all `set` clauses together
    update_stmt := update_stmt
        || array_to_string(updates_todo, ',')
        || format(' from (select * from public.crashes_cris where public.crashes_cris.id = %s) as cris_record', new.id)
        || format(' where public.crashes.id = %s ', new.id);
    raise debug 'Updating unified crashes record from edit update';
    execute (update_stmt) using new;
    return null;
end;
$_$;


--
-- Name: crashes_set_spatial_attributes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crashes_set_spatial_attributes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (new.latitude is not null and new.longitude is not null) then
        -- save lat/lon into geometry col
        new.position = st_setsrid(st_makepoint(new.longitude, new.latitude), 4326);
        --
        -- get location polygon id
        --
        if (new.rpt_road_part_id != 2 and upper(ltrim(new.rpt_hwy_num)) in ('35', '183','183A','1','290','71','360','620','45','130')) then
            -- use level 5 polygon
            new.location_id = (
                select
                    location_id
                from
                    public.atd_txdot_locations
                where
                    location_group = 2 -- level 5
                    and st_contains(geometry, new.position)
                limit 1);
        else
            -- use the other polygons
            new.location_id = (
                select
                    location_id
                from
                    public.atd_txdot_locations
                where
                    location_group = 1 -- not level 5
                    and st_contains(geometry, new.position)
                limit 1);
        end if;

        raise debug 'found location: % compared to previous location: %', new.location_id, old.location_id;
        --
        -- check if in austin full purpose jurisdiction
        --
        new.in_austin_full_purpose =  st_contains((select geometry from atd_jurisdictions where id = 5), new.position);
        raise debug 'in austin full purpose: % compared to previous: %', new.in_austin_full_purpose, old.in_austin_full_purpose;
        --
        -- get council district
        --
        new.council_district = (
            select
                council_district
            from
                public.council_districts
            where
                st_contains(geometry, new.position)
            limit 1);
        raise debug 'council_district: % compared to previous: %', new.council_district, old.council_district;
        --
        -- get engineering area
        --
        new.engineering_area_id = (
            select
                area_id
            from
                public.engineering_areas
            where
                st_contains(geometry, new.position)
            limit 1);
        raise debug 'engineering_area_id: % compared to previous: %', new.engineering_area_id, old.engineering_area_id;
        else
            raise debug 'setting location id and council district to null';
            -- nullify position column
            new.position = null;
            -- reset location id
            new.location_id = null;
            -- use city id to determine full purpose jurisdiction
            new.in_austin_full_purpose = coalesce(new.rpt_city_id = 22, false);
            raise debug 'setting in_austin_full_purpose based on city id: %', new.in_austin_full_purpose;
            -- reset council district
            new.council_district = null;
            -- reset engineering area
            new.engineering_area_id = null;
    end if;
    return new;
end;
$$;


--
-- Name: ems_incidents_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ems_incidents_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  update ems__incidents set
    austin_full_purpose = (
      select ST_Contains(jurisdiction.geometry, incidents.geometry)
      from ems__incidents incidents
      left join atd_jurisdictions jurisdiction on (jurisdiction.jurisdiction_label = 'AUSTIN FULL PURPOSE')
      where incidents.id = new.id),
    location_id = (
      select locations.location_id
      from ems__incidents incidents
      join atd_txdot_locations locations on (locations.location_group = 1 and incidents.geometry && locations.geometry and ST_Contains(locations.geometry, incidents.geometry))
      where incidents.id = new.id),
    latitude = ST_Y(ems__incidents.geometry),
    longitude = ST_X(ems__incidents.geometry),
    apd_incident_number_1 = ems__incidents.apd_incident_numbers[1],
    apd_incident_number_2 = ems__incidents.apd_incident_numbers[2],
    mvc_form_date = date(ems__incidents.mvc_form_extrication_datetime),
    mvc_form_time = ems__incidents.mvc_form_extrication_datetime::time
    where ems__incidents.id = new.id;
RETURN NEW;
END;
$$;


--
-- Name: exec(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.exec(text) RETURNS text
    LANGUAGE plpgsql
    AS $_$ BEGIN EXECUTE $1; RETURN $1; END; $_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: atd_jurisdictions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atd_jurisdictions (
    id integer NOT NULL,
    city_name character varying(30),
    jurisdiction_label character varying(50),
    geometry public.geometry(MultiPolygon,4326)
);


--
-- Name: find_crash_jurisdictions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.find_crash_jurisdictions(given_crash_id integer) RETURNS SETOF public.atd_jurisdictions
    LANGUAGE sql STABLE
    AS $$

(

    SELECT aj.*

    FROM atd_txdot_crashes AS atc

        INNER JOIN atd_jurisdictions aj

        ON ( 1=1

            AND (aj.geometry && atc.position)

            AND ST_Contains(aj.geometry, atc.position)

        )

    WHERE 1=1

    AND atc.crash_id = given_crash_id

)

$$;


--
-- Name: insert_change_log(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_change_log() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
    update_stmt text := 'insert into public.';
    record_json jsonb;
begin
    record_json = jsonb_build_object('new', to_jsonb(new), 'old', to_jsonb(old));
    update_stmt := format('insert into public.change_log_%I (record_id, operation_type, record_json, created_by) 
        values (%s, %L, %L, $1.%I)', TG_TABLE_NAME, new.id, TG_OP, record_json, 'updated_by');
    execute (update_stmt) using new;
    return null;
END;
$_$;


--
-- Name: people_cris_insert_rows(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.people_cris_insert_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.people (
        created_by,
        drvr_city_name,
        drvr_drg_cat_1_id,
        drvr_lic_type_id,
        drvr_zip,
        id,
        is_deleted,
        is_primary_person,
        prsn_age,
        prsn_alc_rslt_id,
        prsn_alc_spec_type_id,
        prsn_bac_test_rslt,
        prsn_death_timestamp,
        prsn_drg_rslt_id,
        prsn_drg_spec_type_id,
        prsn_ethnicity_id,
        prsn_exp_homelessness,
        prsn_first_name,
        prsn_gndr_id,
        prsn_helmet_id,
        prsn_injry_sev_id,
        prsn_last_name,
        prsn_mid_name,
        prsn_name_sfx,
        prsn_nbr,
        prsn_occpnt_pos_id,
        prsn_rest_id,
        prsn_taken_by,
        prsn_taken_to,
        prsn_type_id,
        unit_id,
        updated_by
    ) values (
        new.created_by,
        new.drvr_city_name,
        new.drvr_drg_cat_1_id,
        new.drvr_lic_type_id,
        new.drvr_zip,
        new.id,
        new.is_deleted,
        new.is_primary_person,
        new.prsn_age,
        new.prsn_alc_rslt_id,
        new.prsn_alc_spec_type_id,
        new.prsn_bac_test_rslt,
        new.prsn_death_timestamp,
        new.prsn_drg_rslt_id,
        new.prsn_drg_spec_type_id,
        new.prsn_ethnicity_id,
        new.prsn_exp_homelessness,
        new.prsn_first_name,
        new.prsn_gndr_id,
        new.prsn_helmet_id,
        new.prsn_injry_sev_id,
        new.prsn_last_name,
        new.prsn_mid_name,
        new.prsn_name_sfx,
        new.prsn_nbr,
        new.prsn_occpnt_pos_id,
        new.prsn_rest_id,
        new.prsn_taken_by,
        new.prsn_taken_to,
        new.prsn_type_id,
        new.unit_id,
        new.updated_by
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.people_edits (id) values (new.id);

    RETURN NULL;
END;
$$;


--
-- Name: people_cris_set_unit_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.people_cris_set_unit_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   unit_record record;
BEGIN
    if new.unit_id is not null then
        -- a user may manually create a person record through a
        -- nested Hasura mutation (eg when creating a temp record)
        -- in which case the record will already have a unit_id
        return new;
    end if;
    SELECT INTO unit_record *
        FROM public.units_cris where cris_crash_id = new.cris_crash_id and unit_nbr = new.unit_nbr;
    new.unit_id = unit_record.id;
    RETURN new;
END;
$$;


--
-- Name: people_cris_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.people_cris_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
    new_cris_jb jsonb := to_jsonb (new);
    old_cris_jb jsonb := to_jsonb (old);
    edit_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.people set ';
begin
    -- get corresponding the VZ record as jsonb
    SELECT to_jsonb(people_edits) INTO edit_record_jb from public.people_edits where public.people_edits.id = new.id;

    -- for every key in the cris json object
    for column_name in select jsonb_object_keys(new_cris_jb) loop
        -- ignore audit fields
        continue when column_name in ('created_at', 'updated_at', 'created_by', 'updated_by');
        -- if the new value doesn't match the old
        if(new_cris_jb -> column_name <> old_cris_jb -> column_name) then
            -- see if the vz record has a value for this field
            if (edit_record_jb ->> column_name is  null) then
                -- this value is not overridden by VZ
                -- so update the unified record with this new value
                updates_todo := updates_todo || format('%I = $1.%I', column_name, column_name);
            end if;
        end if;
    end loop;
    if(array_length(updates_todo, 1) > 0) then
        -- set audit field updated_by to match cris record
        updates_todo := updates_todo || format('%I = $1.%I', 'updated_by', 'updated_by');
        -- complete the update statement by joining all `set` clauses together
        update_stmt := update_stmt
            || array_to_string(updates_todo, ',')
            || format(' where public.people.id = %s', new.id);
        raise debug 'Updating people record from CRIS update';
        execute (update_stmt) using new;
    else
        raise debug 'No changes to unified record needed';
    end if;
    return null;
end;
$_$;


--
-- Name: people_edits_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.people_edits_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
    new_edits_jb jsonb := to_jsonb (new);
    cris_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.people set ';
begin
    -- get corresponding the cris record as jsonb
    SELECT to_jsonb(people_cris) INTO cris_record_jb from public.people_cris where public.people_cris.id = new.id;
    -- for every key in the vz json object
    for column_name in select jsonb_object_keys(new_edits_jb) loop
        -- ignore audit fields, except updated_by
        continue when column_name in ('created_at', 'updated_at', 'created_by');
        --  create a set statement for the column
        if cris_record_jb ? column_name then
            -- if this column exists on the cris table, coalesce vz + cris values
            updates_todo := updates_todo
            || format('%I = coalesce($1.%I, cris_record.%I)', column_name, column_name, column_name);
        else
            updates_todo := updates_todo
            || format('%I = $1.%I', column_name, column_name);
        end if;
    end loop;
    -- join all `set` clauses together
    update_stmt := update_stmt
        || array_to_string(updates_todo, ',')
        || format(' from (select * from public.people_cris where public.people_cris.id = %s) as cris_record', new.id)
        || format(' where public.people.id = %s ', new.id);
    raise debug 'Updating unified people record from edit update';
    execute (update_stmt) using new;
    return null;
end;
$_$;


--
-- Name: set_current_timestamp_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$

DECLARE

  _new record;

BEGIN

  _new := NEW;

  _new."updated_at" = NOW();

  RETURN _new;

END;

$$;


--
-- Name: set_updated_at_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    new.updated_at := now();
    return new;
end;
$$;


--
-- Name: units_cris_insert_rows(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.units_cris_insert_rows() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.units (
        autonomous_unit_id,
        contrib_factr_1_id,
        contrib_factr_2_id,
        contrib_factr_3_id,
        contrib_factr_p1_id,
        contrib_factr_p2_id,
        crash_pk,
        created_by,
        cris_crash_id,
        e_scooter_id,
        first_harm_evt_inv_id,
        id,
        is_deleted,
        pbcat_pedalcyclist_id,
        pbcat_pedestrian_id,
        pedalcyclist_action_id,
        pedestrian_action_id,
        rpt_autonomous_level_engaged_id,
        unit_desc_id,
        unit_nbr,
        updated_by,
        veh_body_styl_id,
        veh_damage_description1_id,
        veh_damage_description2_id,
        veh_damage_direction_of_force1_id,
        veh_damage_direction_of_force2_id,
        veh_damage_severity1_id,
        veh_damage_severity2_id,
        veh_hnr_fl,
        veh_make_id,
        veh_mod_id,
        veh_mod_year,
        veh_trvl_dir_id,
        vin
    ) values (
        new.autonomous_unit_id,
        new.contrib_factr_1_id,
        new.contrib_factr_2_id,
        new.contrib_factr_3_id,
        new.contrib_factr_p1_id,
        new.contrib_factr_p2_id,
        new.crash_pk,
        new.created_by,
        new.cris_crash_id,
        new.e_scooter_id,
        new.first_harm_evt_inv_id,
        new.id,
        new.is_deleted,
        new.pbcat_pedalcyclist_id,
        new.pbcat_pedestrian_id,
        new.pedalcyclist_action_id,
        new.pedestrian_action_id,
        new.rpt_autonomous_level_engaged_id,
        new.unit_desc_id,
        new.unit_nbr,
        new.updated_by,
        new.veh_body_styl_id,
        new.veh_damage_description1_id,
        new.veh_damage_description2_id,
        new.veh_damage_direction_of_force1_id,
        new.veh_damage_direction_of_force2_id,
        new.veh_damage_severity1_id,
        new.veh_damage_severity2_id,
        new.veh_hnr_fl,
        new.veh_make_id,
        new.veh_mod_id,
        new.veh_mod_year,
        new.veh_trvl_dir_id,
        new.vin
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.units_edits (id) values (new.id);

    RETURN NULL;
END;
$$;


--
-- Name: units_cris_set_unit_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.units_cris_set_unit_id() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   crash_record record;
BEGIN
    if new.crash_pk is not null then
        -- a user may manually create a unit record through a
        -- nested Hasura mutation (eg when creating a temp record)
        -- in which case the unit record will already have a crash_pk
        return new;
    end if;
    SELECT INTO crash_record *
        FROM public.crashes_cris where cris_crash_id = new.cris_crash_id;
    new.crash_pk = crash_record.id;
    RETURN new;
END;
$$;


--
-- Name: units_cris_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.units_cris_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
    new_cris_jb jsonb := to_jsonb (new);
    old_cris_jb jsonb := to_jsonb (old);
    edit_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.units set ';
begin
    -- get corresponding the VZ record as jsonb
    SELECT to_jsonb(units_edits) INTO edit_record_jb from public.units_edits where public.units_edits.id = new.id;

    -- for every key in the cris json object
    for column_name in select jsonb_object_keys(new_cris_jb) loop
        -- ignore audit fields
        continue when column_name in ('created_at', 'updated_at', 'created_by', 'updated_by');
        -- if the new value doesn't match the old
        if(new_cris_jb -> column_name <> old_cris_jb -> column_name) then
            -- see if the vz record has a value for this field
            if (edit_record_jb ->> column_name is  null) then
                -- this value is not overridden by VZ
                -- so update the unified record with this new value
                updates_todo := updates_todo || format('%I = $1.%I', column_name, column_name);
            end if;
        end if;
    end loop;
    if(array_length(updates_todo, 1) > 0) then
        -- set audit field updated_by to match cris record
        updates_todo := updates_todo || format('%I = $1.%I', 'updated_by', 'updated_by');
        -- complete the update statement by joining all `set` clauses together
        update_stmt := update_stmt
            || array_to_string(updates_todo, ',')
            || format(' where public.units.id = %s', new.id);
        raise debug 'Updating units record from CRIS update';
        execute (update_stmt) using new;
    else
        raise debug 'No changes to unified record needed';
    end if;
    return null;
end;
$_$;


--
-- Name: units_edits_update(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.units_edits_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
    new_edits_jb jsonb := to_jsonb (new);
    cris_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.units set ';
begin
    -- get corresponding the cris record as jsonb
    SELECT to_jsonb(units_cris) INTO cris_record_jb from public.units_cris where public.units_cris.id = new.id;
    -- for every key in the vz json object
    for column_name in select jsonb_object_keys(new_edits_jb) loop
        -- ignore audit fields, except updated_by
        continue when column_name in ('created_at', 'updated_at', 'created_by');
        --  create a set statement for the column
        if cris_record_jb ? column_name then
            -- if this column exists on the cris table, coalesce vz + cris values
            updates_todo := updates_todo
            || format('%I = coalesce($1.%I, cris_record.%I)', column_name, column_name, column_name);
        else
            updates_todo := updates_todo
            || format('%I = $1.%I', column_name, column_name);
        end if;
    end loop;
    -- join all `set` clauses together
    update_stmt := update_stmt
        || array_to_string(updates_todo, ',')
        || format(' from (select * from public.units_cris where public.units_cris.id = %s) as cris_record', new.id)
        || format(' where public.units.id = %s ', new.id);
    raise debug 'Updating unified units record from edit update';
    execute (update_stmt) using new;
    return null;
end;
$_$;


--
-- Name: update_noncr3_location(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_noncr3_location() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: agency; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.agency (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: autonomous_level_engaged; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.autonomous_level_engaged (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: autonomous_unit; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.autonomous_unit (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: city; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.city (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: cnty; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.cnty (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: collsn; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.collsn (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: contrib_factr; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.contrib_factr (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: drvr_ethncty; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.drvr_ethncty (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: drvr_lic_type; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.drvr_lic_type (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: TABLE drvr_lic_type; Type: COMMENT; Schema: lookups; Owner: -
--

COMMENT ON TABLE lookups.drvr_lic_type IS 'Lookup table for driver''s license types';


--
-- Name: e_scooter; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.e_scooter (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: gndr; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.gndr (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: harm_evnt; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.harm_evnt (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: helmet; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.helmet (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: injry_sev; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.injry_sev (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL,
    CONSTRAINT injry_sev_owner_check CHECK ((((id < 99) AND (source = 'cris'::text)) OR ((id >= 99) AND (source = 'vz'::text))))
);


--
-- Name: intrsct_relat; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.intrsct_relat (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: light_cond; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.light_cond (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: mode_category; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.mode_category (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: movt; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.movt (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: obj_struck; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.obj_struck (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: occpnt_pos; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.occpnt_pos (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: pbcat_pedalcyclist; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.pbcat_pedalcyclist (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: pbcat_pedestrian; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.pbcat_pedestrian (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: pedalcyclist_action; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.pedalcyclist_action (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: pedestrian_action; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.pedestrian_action (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: prsn_type; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.prsn_type (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: rest; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.rest (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: road_part; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.road_part (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: rwy_sys; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.rwy_sys (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: specimen_type; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.specimen_type (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: substnc_cat; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.substnc_cat (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: substnc_tst_result; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.substnc_tst_result (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: surf_cond; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.surf_cond (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: surf_type; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.surf_type (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: traffic_cntl; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.traffic_cntl (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: trvl_dir; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.trvl_dir (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: unit_desc; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.unit_desc (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL,
    CONSTRAINT unit_desc_owner_check CHECK ((((id < 177) AND (source = 'cris'::text)) OR ((id >= 177) AND (source = 'vz'::text))))
);


--
-- Name: veh_body_styl; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.veh_body_styl (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL,
    CONSTRAINT veh_body_styl_owner_check CHECK ((((id < 177) AND (source = 'cris'::text)) OR ((id >= 177) AND (source = 'vz'::text))))
);


--
-- Name: veh_damage_description; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.veh_damage_description (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: veh_damage_severity; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.veh_damage_severity (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: veh_direction_of_force; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.veh_direction_of_force (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: veh_make; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.veh_make (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: veh_mod; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.veh_mod (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: wthr_cond; Type: TABLE; Schema: lookups; Owner: -
--

CREATE TABLE lookups.wthr_cond (
    id integer NOT NULL,
    label text NOT NULL,
    source text DEFAULT 'cris'::text NOT NULL
);


--
-- Name: _column_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._column_metadata (
    id integer NOT NULL,
    column_name text NOT NULL,
    record_type text NOT NULL,
    is_imported_from_cris boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE _column_metadata; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public._column_metadata IS 'Table which tracks column metadata for crashes, units, people, and charges records. Is the used by CRIS import to determine which fields will be processed/upserted.';


--
-- Name: COLUMN _column_metadata.column_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._column_metadata.column_name IS 'The name of the column in the db';


--
-- Name: COLUMN _column_metadata.record_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._column_metadata.record_type IS 'The type of record tables associated with this colum: crashes/units/people/charges';


--
-- Name: COLUMN _column_metadata.is_imported_from_cris; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._column_metadata.is_imported_from_cris IS 'If this column is populated via the CRIS import ETL';


--
-- Name: _column_metadata_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public._column_metadata_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: _column_metadata_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public._column_metadata_id_seq OWNED BY public._column_metadata.id;


--
-- Name: _cris_import_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public._cris_import_log (
    id integer NOT NULL,
    object_path text NOT NULL,
    object_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    records_processed jsonb
);


--
-- Name: COLUMN _cris_import_log.object_path; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._cris_import_log.object_path IS 'The location within the bucket where the extract was found';


--
-- Name: COLUMN _cris_import_log.object_name; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._cris_import_log.object_name IS 'The name of the object (file) within the bucket';


--
-- Name: COLUMN _cris_import_log.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._cris_import_log.created_at IS 'Audit field for when the import started';


--
-- Name: COLUMN _cris_import_log.completed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._cris_import_log.completed_at IS 'Audit field for when the import finished';


--
-- Name: COLUMN _cris_import_log.records_processed; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public._cris_import_log.records_processed IS 'A JSON blob that contains counts or a list of crashes imported per schema';


--
-- Name: _lookup_tables_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public._lookup_tables_view AS
 SELECT DISTINCT columns.table_name
   FROM information_schema.columns
  WHERE ((columns.table_schema)::name = 'lookups'::name)
  ORDER BY columns.table_name;


--
-- Name: VIEW _lookup_tables_view; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public._lookup_tables_view IS 'View which provides a list of tables in the "lookups" schema and is used by helper script to identify CRIS lookup table changes';


--
-- Name: afd__incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.afd__incidents (
    id integer NOT NULL,
    incident_number integer,
    crash_id integer,
    unparsed_ems_incident_number text,
    ems_incident_numbers integer[],
    call_datetime timestamp without time zone,
    calendar_year text,
    jurisdiction text,
    address text,
    problem text,
    flagged_incs text,
    geometry public.geometry(Point,4326) DEFAULT NULL::public.geometry,
    austin_full_purpose boolean,
    location_id text,
    latitude double precision,
    longitude double precision,
    ems_incident_number_1 integer,
    ems_incident_number_2 integer,
    call_date date,
    call_time time without time zone
);


--
-- Name: afd__incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.afd__incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: afd__incidents_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.afd__incidents_id_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: afd__incidents_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.afd__incidents_id_seq1 OWNED BY public.afd__incidents.id;


--
-- Name: atd__coordination_partners_lkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atd__coordination_partners_lkp (
    id integer NOT NULL,
    coord_partner_desc text NOT NULL
);


--
-- Name: atd__coordination_partners_lkp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.atd__coordination_partners_lkp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: atd__coordination_partners_lkp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.atd__coordination_partners_lkp_id_seq OWNED BY public.atd__coordination_partners_lkp.id;


--
-- Name: atd__recommendation_status_lkp; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atd__recommendation_status_lkp (
    id integer NOT NULL,
    rec_status_desc text NOT NULL
);


--
-- Name: atd__recommendation_status_lkp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.atd__recommendation_status_lkp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: atd__recommendation_status_lkp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.atd__recommendation_status_lkp_id_seq OWNED BY public.atd__recommendation_status_lkp.id;


--
-- Name: atd_apd_blueform; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atd_apd_blueform (
    form_id integer NOT NULL,
    date date NOT NULL,
    case_id integer NOT NULL,
    address text,
    longitude numeric,
    latitude numeric,
    hour integer,
    location_id character varying,
    speed_mgmt_points numeric(10,2) DEFAULT 0.25,
    est_comp_cost numeric(10,2) DEFAULT '51000'::numeric,
    est_econ_cost numeric(10,2) DEFAULT '12376'::numeric,
    "position" public.geometry(Geometry,4326),
    est_comp_cost_crash_based numeric(10,2) DEFAULT 10000
);


--
-- Name: atd_apd_blueform_form_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.atd_apd_blueform_form_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: atd_apd_blueform_form_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.atd_apd_blueform_form_id_seq OWNED BY public.atd_apd_blueform.form_id;


--
-- Name: atd_jurisdictions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.atd_jurisdictions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: atd_jurisdictions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.atd_jurisdictions_id_seq OWNED BY public.atd_jurisdictions.id;


--
-- Name: atd_txdot_locations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.atd_txdot_locations (
    location_id character varying NOT NULL,
    description text NOT NULL,
    last_update date DEFAULT now() NOT NULL,
    latitude double precision,
    longitude double precision,
    scale_factor double precision,
    geometry public.geometry(MultiPolygon,4326),
    street_level character varying(16),
    is_intersection integer DEFAULT 0 NOT NULL,
    council_district integer,
    location_group smallint DEFAULT 0
);


--
-- Name: change_log_crashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_crashes (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_crashes_cris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_crashes_cris (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_crashes_cris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_crashes_cris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_crashes_cris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_crashes_cris_id_seq OWNED BY public.change_log_crashes_cris.id;


--
-- Name: change_log_crashes_edits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_crashes_edits (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_crashes_edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_crashes_edits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_crashes_edits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_crashes_edits_id_seq OWNED BY public.change_log_crashes_edits.id;


--
-- Name: change_log_crashes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_crashes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_crashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_crashes_id_seq OWNED BY public.change_log_crashes.id;


--
-- Name: change_log_people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_people (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_people_cris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_people_cris (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_people_cris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_people_cris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_people_cris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_people_cris_id_seq OWNED BY public.change_log_people_cris.id;


--
-- Name: change_log_people_edits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_people_edits (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_people_edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_people_edits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_people_edits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_people_edits_id_seq OWNED BY public.change_log_people_edits.id;


--
-- Name: change_log_people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_people_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_people_id_seq OWNED BY public.change_log_people.id;


--
-- Name: change_log_units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_units (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_units_cris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_units_cris (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_units_cris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_units_cris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_units_cris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_units_cris_id_seq OWNED BY public.change_log_units_cris.id;


--
-- Name: change_log_units_edits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.change_log_units_edits (
    id integer NOT NULL,
    record_id integer NOT NULL,
    operation_type text NOT NULL,
    record_json jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    created_by text NOT NULL
);


--
-- Name: change_log_units_edits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_units_edits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_units_edits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_units_edits_id_seq OWNED BY public.change_log_units_edits.id;


--
-- Name: change_log_units_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.change_log_units_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: change_log_units_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.change_log_units_id_seq OWNED BY public.change_log_units.id;


--
-- Name: charges_cris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.charges_cris (
    id integer NOT NULL,
    charge text,
    citation_nbr text,
    crash_pk integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer NOT NULL,
    cris_schema_version text NOT NULL,
    person_id integer NOT NULL,
    prsn_nbr integer NOT NULL,
    unit_nbr numeric NOT NULL
);


--
-- Name: charges_cris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.charges_cris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: charges_cris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.charges_cris_id_seq OWNED BY public.charges_cris.id;


--
-- Name: council_districts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.council_districts (
    id integer NOT NULL,
    council_district integer NOT NULL,
    geometry public.geometry(MultiPolygon,4326) NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: council_districts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.council_districts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: council_districts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.council_districts_id_seq OWNED BY public.council_districts.id;


--
-- Name: cr3_mainlanes_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cr3_mainlanes_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crashes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crashes (
    id integer NOT NULL,
    active_school_zone_fl boolean,
    address_primary text GENERATED ALWAYS AS (public.build_crash_address(rpt_block_num, rpt_street_pfx, rpt_street_name, rpt_street_sfx)) STORED,
    address_secondary text GENERATED ALWAYS AS (public.build_crash_address(rpt_sec_block_num, rpt_sec_street_pfx, rpt_sec_street_name, rpt_sec_street_sfx)) STORED,
    at_intrsct_fl boolean,
    case_id text,
    council_district integer,
    cr3_processed_at timestamp with time zone,
    cr3_stored_fl boolean DEFAULT false NOT NULL,
    crash_speed_limit integer,
    crash_timestamp timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer,
    engineering_area_id integer,
    fhe_collsn_id integer,
    in_austin_full_purpose boolean,
    intrsct_relat_id integer,
    investigat_agency_id integer,
    investigator_narrative text,
    is_deleted boolean DEFAULT false NOT NULL,
    is_temp_record boolean DEFAULT false NOT NULL,
    latitude numeric,
    law_enforcement_ytd_fatality_num text,
    light_cond_id integer,
    location_id text,
    longitude numeric,
    medical_advisory_fl boolean,
    obj_struck_id integer,
    onsys_fl boolean,
    "position" public.geometry(Point,4326),
    private_dr_fl boolean,
    record_locator text GENERATED ALWAYS AS (
CASE
    WHEN (is_temp_record = true) THEN ('T'::text || (id)::text)
    ELSE (cris_crash_id)::text
END) STORED NOT NULL,
    road_constr_zone_fl boolean,
    road_constr_zone_wrkr_fl boolean,
    rpt_block_num text,
    rpt_city_id integer,
    rpt_cris_cnty_id integer,
    rpt_hwy_num text,
    rpt_hwy_sfx text,
    rpt_rdwy_sys_id integer,
    rpt_ref_mark_dir text,
    rpt_ref_mark_dist_uom text,
    rpt_ref_mark_nbr text,
    rpt_ref_mark_offset_amt numeric,
    rpt_road_part_id integer,
    rpt_sec_block_num text,
    rpt_sec_hwy_num text,
    rpt_sec_hwy_sfx text,
    rpt_sec_rdwy_sys_id integer,
    rpt_sec_road_part_id integer,
    rpt_sec_street_desc text,
    rpt_sec_street_name text,
    rpt_sec_street_pfx text,
    rpt_sec_street_sfx text,
    rpt_street_desc text,
    rpt_street_name text,
    rpt_street_pfx text,
    rpt_street_sfx text,
    rr_relat_fl boolean,
    schl_bus_fl boolean,
    surf_cond_id integer,
    surf_type_id integer,
    thousand_damage_fl boolean,
    toll_road_fl boolean,
    traffic_cntl_id integer,
    txdot_rptable_fl boolean,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    wthr_cond_id integer,
    investigator_narrative_ocr_processed_at timestamp with time zone
);


--
-- Name: COLUMN crashes.investigator_narrative_ocr_processed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.crashes.investigator_narrative_ocr_processed_at IS 'The most recent
timestamp at which the OCR process attempted to extract the investigator narrative. If null, 
indicates that the OCR narrative extract has never been attempted. This value should be set
via ETL process on the crashes_edits table.';


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    drvr_city_name text,
    drvr_drg_cat_1_id integer,
    drvr_zip text,
    ems_id integer,
    est_comp_cost_crash_based integer GENERATED ALWAYS AS (
CASE
    WHEN (prsn_injry_sev_id = 1) THEN 3000000
    WHEN (prsn_injry_sev_id = 2) THEN 250000
    WHEN (prsn_injry_sev_id = 3) THEN 200000
    WHEN (prsn_injry_sev_id = 4) THEN 3500000
    ELSE 20000
END) STORED,
    is_deleted boolean DEFAULT false NOT NULL,
    is_primary_person boolean,
    prsn_age integer,
    prsn_alc_rslt_id integer,
    prsn_alc_spec_type_id integer,
    prsn_bac_test_rslt text,
    prsn_death_timestamp timestamp with time zone,
    prsn_drg_rslt_id integer,
    prsn_drg_spec_type_id integer,
    prsn_ethnicity_id integer,
    prsn_exp_homelessness boolean DEFAULT false NOT NULL,
    prsn_first_name text,
    prsn_gndr_id integer,
    prsn_helmet_id integer,
    prsn_injry_sev_id integer,
    prsn_last_name text,
    prsn_mid_name text,
    prsn_name_sfx text,
    prsn_nbr integer,
    prsn_occpnt_pos_id integer,
    prsn_rest_id integer,
    prsn_taken_by text,
    prsn_taken_to text,
    prsn_type_id integer,
    unit_id integer NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    years_of_life_lost integer GENERATED ALWAYS AS (
CASE
    WHEN (prsn_injry_sev_id = 4) THEN GREATEST((75 - prsn_age), 0)
    ELSE 0
END) STORED,
    drvr_lic_type_id integer
);


--
-- Name: COLUMN people.drvr_lic_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.people.drvr_lic_type_id IS 'Driver''s license type';


--
-- Name: people_cris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people_cris (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer,
    cris_schema_version text NOT NULL,
    drvr_city_name text,
    drvr_drg_cat_1_id integer,
    drvr_zip text,
    is_deleted boolean DEFAULT false NOT NULL,
    is_primary_person boolean,
    prsn_age integer,
    prsn_alc_rslt_id integer,
    prsn_alc_spec_type_id integer,
    prsn_bac_test_rslt text,
    prsn_death_timestamp timestamp with time zone,
    prsn_drg_rslt_id integer,
    prsn_drg_spec_type_id integer,
    prsn_ethnicity_id integer,
    prsn_exp_homelessness boolean DEFAULT false NOT NULL,
    prsn_first_name text,
    prsn_gndr_id integer,
    prsn_helmet_id integer,
    prsn_injry_sev_id integer,
    prsn_last_name text,
    prsn_mid_name text,
    prsn_name_sfx text,
    prsn_nbr integer,
    prsn_occpnt_pos_id integer,
    prsn_rest_id integer,
    prsn_taken_by text,
    prsn_taken_to text,
    prsn_type_id integer,
    unit_id integer NOT NULL,
    unit_nbr integer NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    drvr_lic_type_id integer,
    CONSTRAINT people_cris_prsn_injry_sev_id_check CHECK ((prsn_injry_sev_id < 99))
);


--
-- Name: COLUMN people_cris.drvr_lic_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.people_cris.drvr_lic_type_id IS 'Driver''s license type';


--
-- Name: units; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units (
    id integer NOT NULL,
    autonomous_unit_id integer,
    contrib_factr_1_id integer,
    contrib_factr_2_id integer,
    contrib_factr_3_id integer,
    contrib_factr_p1_id integer,
    contrib_factr_p2_id integer,
    crash_pk integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer,
    e_scooter_id integer,
    first_harm_evt_inv_id integer,
    is_deleted boolean DEFAULT false NOT NULL,
    movement_id integer,
    pbcat_pedalcyclist_id integer,
    pbcat_pedestrian_id integer,
    pedalcyclist_action_id integer,
    pedestrian_action_id integer,
    rpt_autonomous_level_engaged_id integer,
    unit_desc_id integer,
    unit_nbr integer NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    veh_body_styl_id integer,
    veh_damage_description1_id integer,
    veh_damage_description2_id integer,
    veh_damage_direction_of_force1_id integer,
    veh_damage_direction_of_force2_id integer,
    veh_damage_severity1_id integer,
    veh_damage_severity2_id integer,
    veh_make_id integer,
    veh_mod_id integer,
    veh_mod_year integer,
    veh_trvl_dir_id integer,
    vin text,
    vz_mode_category_id integer GENERATED ALWAYS AS (
CASE
    WHEN (unit_desc_id = 3) THEN 5
    WHEN (unit_desc_id = 5) THEN 6
    WHEN (unit_desc_id = 4) THEN 7
    WHEN (unit_desc_id = 2) THEN 8
    WHEN (unit_desc_id = 177) THEN
    CASE
        WHEN (veh_body_styl_id = 177) THEN 11
        ELSE 6
    END
    WHEN (unit_desc_id = 1) THEN
    CASE
        WHEN (veh_body_styl_id = ANY (ARRAY[100, 104])) THEN 1
        WHEN (veh_body_styl_id = ANY (ARRAY[30, 69, 103, 106])) THEN 2
        WHEN (veh_body_styl_id = ANY (ARRAY[71, 90])) THEN 3
        ELSE 4
    END
    ELSE 9
END) STORED NOT NULL,
    veh_hnr_fl boolean
);


--
-- Name: COLUMN units.veh_hnr_fl; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.units.veh_hnr_fl IS 'If the unit was involved in a hit-and-run crash. This field may indicate that the unit was the victim of a hit and run, or this unit left the scene/committed the hit and run';


--
-- Name: person_injury_metrics_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.person_injury_metrics_view AS
 SELECT people.id,
    units.id AS unit_id,
    crashes.id AS crash_pk,
    crashes.cris_crash_id,
    people.years_of_life_lost,
    people.est_comp_cost_crash_based,
        CASE
            WHEN (people.prsn_injry_sev_id = 0) THEN 1
            ELSE 0
        END AS unkn_injry,
        CASE
            WHEN (people.prsn_injry_sev_id = 1) THEN 1
            ELSE 0
        END AS sus_serious_injry,
        CASE
            WHEN (people.prsn_injry_sev_id = 2) THEN 1
            ELSE 0
        END AS nonincap_injry,
        CASE
            WHEN (people.prsn_injry_sev_id = 3) THEN 1
            ELSE 0
        END AS poss_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 4) OR (people.prsn_injry_sev_id = 99)) THEN 1
            ELSE 0
        END AS fatal_injury,
        CASE
            WHEN (people.prsn_injry_sev_id = 4) THEN 1
            ELSE 0
        END AS vz_fatal_injury,
        CASE
            WHEN (((people.prsn_injry_sev_id = 4) OR (people.prsn_injry_sev_id = 99)) AND (crashes.law_enforcement_ytd_fatality_num IS NOT NULL)) THEN 1
            ELSE 0
        END AS law_enf_fatal_injury,
        CASE
            WHEN (people_cris.prsn_injry_sev_id = 4) THEN 1
            ELSE 0
        END AS cris_fatal_injury,
        CASE
            WHEN (people.prsn_injry_sev_id = 5) THEN 1
            ELSE 0
        END AS non_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 4) AND (units.vz_mode_category_id = ANY (ARRAY[1, 2, 4]))) THEN 1
            ELSE 0
        END AS motor_vehicle_fatal_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 1) AND (units.vz_mode_category_id = ANY (ARRAY[1, 2, 4]))) THEN 1
            ELSE 0
        END AS motor_vehicle_sus_serious_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 4) AND (units.vz_mode_category_id = 3)) THEN 1
            ELSE 0
        END AS motorcycle_fatal_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 1) AND (units.vz_mode_category_id = 3)) THEN 1
            ELSE 0
        END AS motorycle_sus_serious_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 4) AND (units.vz_mode_category_id = 5)) THEN 1
            ELSE 0
        END AS bicycle_fatal_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 1) AND (units.vz_mode_category_id = 5)) THEN 1
            ELSE 0
        END AS bicycle_sus_serious_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 4) AND (units.vz_mode_category_id = 7)) THEN 1
            ELSE 0
        END AS pedestrian_fatal_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 1) AND (units.vz_mode_category_id = 7)) THEN 1
            ELSE 0
        END AS pedestrian_sus_serious_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 4) AND (units.vz_mode_category_id = 11)) THEN 1
            ELSE 0
        END AS micromobility_fatal_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 1) AND (units.vz_mode_category_id = 11)) THEN 1
            ELSE 0
        END AS micromobility_sus_serious_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 4) AND (units.vz_mode_category_id = ANY (ARRAY[6, 8, 9]))) THEN 1
            ELSE 0
        END AS other_fatal_injry,
        CASE
            WHEN ((people.prsn_injry_sev_id = 1) AND (units.vz_mode_category_id = ANY (ARRAY[6, 8, 9]))) THEN 1
            ELSE 0
        END AS other_sus_serious_injry
   FROM (((public.people people
     LEFT JOIN public.units units ON ((people.unit_id = units.id)))
     LEFT JOIN public.people_cris people_cris ON ((people.id = people_cris.id)))
     LEFT JOIN public.crashes crashes ON ((units.crash_pk = crashes.id)))
  WHERE (people.is_deleted = false);


--
-- Name: crash_injury_metrics_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.crash_injury_metrics_view AS
 SELECT crashes.id,
    crashes.cris_crash_id,
    COALESCE(sum(person_injury_metrics_view.unkn_injry), (0)::bigint) AS unkn_injry_count,
    COALESCE(sum(person_injury_metrics_view.nonincap_injry), (0)::bigint) AS nonincap_injry_count,
    COALESCE(sum(person_injury_metrics_view.poss_injry), (0)::bigint) AS poss_injry_count,
    COALESCE(sum(person_injury_metrics_view.non_injry), (0)::bigint) AS non_injry_count,
    COALESCE(sum(person_injury_metrics_view.sus_serious_injry), (0)::bigint) AS sus_serious_injry_count,
    ((COALESCE(sum(person_injury_metrics_view.nonincap_injry), (0)::bigint) + COALESCE(sum(person_injury_metrics_view.poss_injry), (0)::bigint)) + COALESCE(sum(person_injury_metrics_view.sus_serious_injry), (0)::bigint)) AS tot_injry_count,
    COALESCE(sum(person_injury_metrics_view.fatal_injury), (0)::bigint) AS fatality_count,
    COALESCE(sum(person_injury_metrics_view.vz_fatal_injury), (0)::bigint) AS vz_fatality_count,
    COALESCE(sum(person_injury_metrics_view.law_enf_fatal_injury), (0)::bigint) AS law_enf_fatality_count,
    COALESCE(sum(person_injury_metrics_view.cris_fatal_injury), (0)::bigint) AS cris_fatality_count,
    COALESCE(sum(person_injury_metrics_view.motor_vehicle_fatal_injry), (0)::bigint) AS motor_vehicle_fatality_count,
    COALESCE(sum(person_injury_metrics_view.motor_vehicle_sus_serious_injry), (0)::bigint) AS motor_vehicle_sus_serious_injry_count,
    COALESCE(sum(person_injury_metrics_view.motorcycle_fatal_injry), (0)::bigint) AS motorcycle_fatality_count,
    COALESCE(sum(person_injury_metrics_view.motorycle_sus_serious_injry), (0)::bigint) AS motorcycle_sus_serious_count,
    COALESCE(sum(person_injury_metrics_view.bicycle_fatal_injry), (0)::bigint) AS bicycle_fatality_count,
    COALESCE(sum(person_injury_metrics_view.bicycle_sus_serious_injry), (0)::bigint) AS bicycle_sus_serious_injry_count,
    COALESCE(sum(person_injury_metrics_view.pedestrian_fatal_injry), (0)::bigint) AS pedestrian_fatality_count,
    COALESCE(sum(person_injury_metrics_view.pedestrian_sus_serious_injry), (0)::bigint) AS pedestrian_sus_serious_injry_count,
    COALESCE(sum(person_injury_metrics_view.micromobility_fatal_injry), (0)::bigint) AS micromobility_fatality_count,
    COALESCE(sum(person_injury_metrics_view.micromobility_sus_serious_injry), (0)::bigint) AS micromobility_sus_serious_injry_count,
    COALESCE(sum(person_injury_metrics_view.other_fatal_injry), (0)::bigint) AS other_fatality_count,
    COALESCE(sum(person_injury_metrics_view.other_sus_serious_injry), (0)::bigint) AS other_sus_serious_injry_count,
        CASE
            WHEN (sum(person_injury_metrics_view.fatal_injury) > 0) THEN 4
            WHEN (sum(person_injury_metrics_view.sus_serious_injry) > 0) THEN 1
            WHEN (sum(person_injury_metrics_view.nonincap_injry) > 0) THEN 2
            WHEN (sum(person_injury_metrics_view.poss_injry) > 0) THEN 3
            WHEN (sum(person_injury_metrics_view.unkn_injry) > 0) THEN 0
            WHEN (sum(person_injury_metrics_view.non_injry) > 0) THEN 5
            ELSE 0
        END AS crash_injry_sev_id,
    COALESCE(sum(person_injury_metrics_view.years_of_life_lost), (0)::bigint) AS years_of_life_lost,
    COALESCE(max(person_injury_metrics_view.est_comp_cost_crash_based), 20000) AS est_comp_cost_crash_based,
    COALESCE(sum(person_injury_metrics_view.est_comp_cost_crash_based), (20000)::bigint) AS est_total_person_comp_cost
   FROM (public.crashes crashes
     LEFT JOIN public.person_injury_metrics_view ON ((crashes.id = person_injury_metrics_view.crash_pk)))
  WHERE (crashes.is_deleted = false)
  GROUP BY crashes.id, crashes.cris_crash_id;


--
-- Name: crash_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crash_notes (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    date timestamp with time zone DEFAULT now() NOT NULL,
    text text NOT NULL,
    user_email text,
    crash_pk integer NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL
);


--
-- Name: crashes_change_log_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.crashes_change_log_view AS
 SELECT concat('crash_', change_log_crashes.id) AS id,
    'crash'::text AS record_type,
    change_log_crashes.record_id AS crash_pk,
    change_log_crashes.record_id,
        CASE
            WHEN (change_log_crashes.operation_type = 'INSERT'::text) THEN 'create'::text
            ELSE lower(change_log_crashes.operation_type)
        END AS operation_type,
    change_log_crashes.record_json,
    change_log_crashes.created_at,
    change_log_crashes.created_by
   FROM public.change_log_crashes
UNION ALL
 SELECT concat('unit_', change_log_units.id) AS id,
    'unit'::text AS record_type,
    units.crash_pk,
    change_log_units.record_id,
        CASE
            WHEN (change_log_units.operation_type = 'INSERT'::text) THEN 'create'::text
            ELSE lower(change_log_units.operation_type)
        END AS operation_type,
    change_log_units.record_json,
    change_log_units.created_at,
    change_log_units.created_by
   FROM (public.change_log_units
     LEFT JOIN public.units ON ((change_log_units.record_id = units.id)))
UNION ALL
 SELECT concat('people_', change_log_people.id) AS id,
    'person'::text AS record_type,
    crashes.id AS crash_pk,
    change_log_people.record_id,
        CASE
            WHEN (change_log_people.operation_type = 'INSERT'::text) THEN 'create'::text
            ELSE lower(change_log_people.operation_type)
        END AS operation_type,
    change_log_people.record_json,
    change_log_people.created_at,
    change_log_people.created_by
   FROM (((public.change_log_people
     LEFT JOIN public.people ON ((change_log_people.record_id = people.id)))
     LEFT JOIN public.units ON ((people.unit_id = units.id)))
     LEFT JOIN public.crashes ON ((units.crash_pk = crashes.id)));


--
-- Name: crashes_cris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crashes_cris (
    id integer NOT NULL,
    active_school_zone_fl boolean,
    at_intrsct_fl boolean,
    case_id text,
    cr3_processed_at timestamp with time zone,
    cr3_stored_fl boolean DEFAULT false NOT NULL,
    crash_speed_limit integer,
    crash_timestamp timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer,
    cris_schema_version text NOT NULL,
    fhe_collsn_id integer,
    intrsct_relat_id integer,
    investigat_agency_id integer,
    investigator_narrative text,
    is_deleted boolean DEFAULT false NOT NULL,
    is_temp_record boolean DEFAULT false NOT NULL,
    latitude numeric,
    light_cond_id integer,
    longitude numeric,
    medical_advisory_fl boolean,
    obj_struck_id integer,
    onsys_fl boolean,
    private_dr_fl boolean,
    road_constr_zone_fl boolean,
    road_constr_zone_wrkr_fl boolean,
    rpt_block_num text,
    rpt_city_id integer,
    rpt_cris_cnty_id integer,
    rpt_hwy_num text,
    rpt_hwy_sfx text,
    rpt_rdwy_sys_id integer,
    rpt_ref_mark_dir text,
    rpt_ref_mark_dist_uom text,
    rpt_ref_mark_nbr text,
    rpt_ref_mark_offset_amt numeric,
    rpt_road_part_id integer,
    rpt_sec_block_num text,
    rpt_sec_hwy_num text,
    rpt_sec_hwy_sfx text,
    rpt_sec_rdwy_sys_id integer,
    rpt_sec_road_part_id integer,
    rpt_sec_street_desc text,
    rpt_sec_street_name text,
    rpt_sec_street_pfx text,
    rpt_sec_street_sfx text,
    rpt_street_desc text,
    rpt_street_name text,
    rpt_street_pfx text,
    rpt_street_sfx text,
    rr_relat_fl boolean,
    schl_bus_fl boolean,
    surf_cond_id integer,
    surf_type_id integer,
    thousand_damage_fl boolean,
    toll_road_fl boolean,
    traffic_cntl_id integer,
    txdot_rptable_fl boolean,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    wthr_cond_id integer
);


--
-- Name: crashes_cris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.crashes_cris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: crashes_cris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.crashes_cris_id_seq OWNED BY public.crashes_cris.id;


--
-- Name: crashes_edits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.crashes_edits (
    id integer NOT NULL,
    active_school_zone_fl boolean,
    at_intrsct_fl boolean,
    case_id text,
    cr3_processed_at timestamp with time zone,
    cr3_stored_fl boolean,
    crash_speed_limit integer,
    crash_timestamp timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer,
    fhe_collsn_id integer,
    intrsct_relat_id integer,
    investigat_agency_id integer,
    investigator_narrative text,
    is_deleted boolean,
    is_temp_record boolean,
    latitude numeric,
    law_enforcement_ytd_fatality_num text,
    light_cond_id integer,
    longitude numeric,
    medical_advisory_fl boolean,
    obj_struck_id integer,
    onsys_fl boolean,
    private_dr_fl boolean,
    road_constr_zone_fl boolean,
    road_constr_zone_wrkr_fl boolean,
    rpt_block_num text,
    rpt_city_id integer,
    rpt_cris_cnty_id integer,
    rpt_hwy_num text,
    rpt_hwy_sfx text,
    rpt_rdwy_sys_id integer,
    rpt_ref_mark_dir text,
    rpt_ref_mark_dist_uom text,
    rpt_ref_mark_nbr text,
    rpt_ref_mark_offset_amt numeric,
    rpt_road_part_id integer,
    rpt_sec_block_num text,
    rpt_sec_hwy_num text,
    rpt_sec_hwy_sfx text,
    rpt_sec_rdwy_sys_id integer,
    rpt_sec_road_part_id integer,
    rpt_sec_street_desc text,
    rpt_sec_street_name text,
    rpt_sec_street_pfx text,
    rpt_sec_street_sfx text,
    rpt_street_desc text,
    rpt_street_name text,
    rpt_street_pfx text,
    rpt_street_sfx text,
    rr_relat_fl boolean,
    schl_bus_fl boolean,
    surf_cond_id integer,
    surf_type_id integer,
    thousand_damage_fl boolean,
    toll_road_fl boolean,
    traffic_cntl_id integer,
    txdot_rptable_fl boolean,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    wthr_cond_id integer,
    investigator_narrative_ocr_processed_at timestamp with time zone
);


--
-- Name: COLUMN crashes_edits.investigator_narrative_ocr_processed_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.crashes_edits.investigator_narrative_ocr_processed_at IS 'The most recent
timestamp at which the OCR process attempted to extract the investigator narrative. If null, 
indicates that the OCR narrative extract has never been attempted. This value should be set
via ETL process.';


--
-- Name: crashes_list_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.crashes_list_view AS
 WITH geocode_status AS (
         SELECT cris.id,
            ((edits.latitude IS NOT NULL) OR (edits.longitude IS NOT NULL)) AS is_manual_geocode
           FROM (public.crashes_cris cris
             LEFT JOIN public.crashes_edits edits ON ((cris.id = edits.id)))
        )
 SELECT crashes.id,
    crashes.cris_crash_id,
    crashes.record_locator,
    crashes.case_id,
    crashes.crash_timestamp,
    crashes.address_primary,
    crashes.address_secondary,
    crashes.private_dr_fl,
    crashes.in_austin_full_purpose,
    crashes.location_id,
    crashes.rpt_block_num,
    crashes.rpt_street_pfx,
    crashes.rpt_street_sfx,
    crashes.rpt_street_name,
    crashes.rpt_sec_block_num,
    crashes.rpt_sec_street_pfx,
    crashes.rpt_sec_street_sfx,
    crashes.rpt_sec_street_name,
    crashes.latitude,
    crashes.longitude,
    crashes.light_cond_id,
    crashes.wthr_cond_id,
    crashes.active_school_zone_fl,
    crashes.schl_bus_fl,
    crashes.at_intrsct_fl,
    crashes.onsys_fl,
    crashes.traffic_cntl_id,
    crashes.road_constr_zone_fl,
    crashes.rr_relat_fl,
    crashes.toll_road_fl,
    crashes.intrsct_relat_id,
    crashes.obj_struck_id,
    crashes.crash_speed_limit,
    crashes.council_district,
    crashes.is_temp_record,
    crash_injury_metrics_view.nonincap_injry_count,
    crash_injury_metrics_view.poss_injry_count,
    crash_injury_metrics_view.sus_serious_injry_count,
    crash_injury_metrics_view.non_injry_count,
    crash_injury_metrics_view.tot_injry_count,
    crash_injury_metrics_view.vz_fatality_count,
    crash_injury_metrics_view.cris_fatality_count,
    crash_injury_metrics_view.law_enf_fatality_count,
    crash_injury_metrics_view.fatality_count,
    crash_injury_metrics_view.unkn_injry_count,
    crash_injury_metrics_view.est_comp_cost_crash_based,
    crash_injury_metrics_view.crash_injry_sev_id,
    crash_injury_metrics_view.years_of_life_lost,
    injry_sev.label AS crash_injry_sev_desc,
    collsn.label AS collsn_desc,
    geocode_status.is_manual_geocode,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'YYYY-MM-DD'::text) AS crash_date_ct,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'HH24:MI:SS'::text) AS crash_time_ct,
    upper(to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'dy'::text)) AS crash_day_of_week
   FROM ((((public.crashes
     LEFT JOIN LATERAL ( SELECT crash_injury_metrics_view_1.id,
            crash_injury_metrics_view_1.cris_crash_id,
            crash_injury_metrics_view_1.unkn_injry_count,
            crash_injury_metrics_view_1.nonincap_injry_count,
            crash_injury_metrics_view_1.poss_injry_count,
            crash_injury_metrics_view_1.non_injry_count,
            crash_injury_metrics_view_1.sus_serious_injry_count,
            crash_injury_metrics_view_1.tot_injry_count,
            crash_injury_metrics_view_1.fatality_count,
            crash_injury_metrics_view_1.vz_fatality_count,
            crash_injury_metrics_view_1.law_enf_fatality_count,
            crash_injury_metrics_view_1.cris_fatality_count,
            crash_injury_metrics_view_1.motor_vehicle_fatality_count,
            crash_injury_metrics_view_1.motor_vehicle_sus_serious_injry_count,
            crash_injury_metrics_view_1.motorcycle_fatality_count,
            crash_injury_metrics_view_1.motorcycle_sus_serious_count,
            crash_injury_metrics_view_1.bicycle_fatality_count,
            crash_injury_metrics_view_1.bicycle_sus_serious_injry_count,
            crash_injury_metrics_view_1.pedestrian_fatality_count,
            crash_injury_metrics_view_1.pedestrian_sus_serious_injry_count,
            crash_injury_metrics_view_1.micromobility_fatality_count,
            crash_injury_metrics_view_1.micromobility_sus_serious_injry_count,
            crash_injury_metrics_view_1.other_fatality_count,
            crash_injury_metrics_view_1.other_sus_serious_injry_count,
            crash_injury_metrics_view_1.crash_injry_sev_id,
            crash_injury_metrics_view_1.years_of_life_lost,
            crash_injury_metrics_view_1.est_comp_cost_crash_based,
            crash_injury_metrics_view_1.est_total_person_comp_cost
           FROM public.crash_injury_metrics_view crash_injury_metrics_view_1
          WHERE (crashes.id = crash_injury_metrics_view_1.id)
         LIMIT 1) crash_injury_metrics_view ON (true))
     LEFT JOIN geocode_status ON ((crashes.id = geocode_status.id)))
     LEFT JOIN lookups.collsn ON ((crashes.fhe_collsn_id = collsn.id)))
     LEFT JOIN lookups.injry_sev ON ((crash_injury_metrics_view.crash_injry_sev_id = injry_sev.id)))
  WHERE (crashes.is_deleted = false)
  ORDER BY crashes.crash_timestamp DESC;


--
-- Name: cris_import_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cris_import_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cris_import_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cris_import_log_id_seq OWNED BY public._cris_import_log.id;


--
-- Name: ems__incidents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ems__incidents (
    id integer NOT NULL,
    pcr_key integer NOT NULL,
    crash_id integer,
    incident_date_received date,
    incident_time_received time without time zone,
    incident_number text,
    incident_location_address text,
    incident_location_city text,
    incident_location_state text,
    incident_location_zip text,
    incident_location_longitude double precision,
    incident_location_latitude double precision,
    incident_problem text,
    incident_priority_number text,
    pcr_cause_of_injury text,
    pcr_patient_complaints text,
    pcr_provider_impression_primary text,
    pcr_provider_impression_secondary text,
    pcr_outcome text,
    pcr_transport_destination text,
    pcr_patient_acuity_level text,
    pcr_patient_acuity_level_reason text,
    pcr_patient_age integer,
    pcr_patient_gender text,
    pcr_patient_race text,
    mvc_form_airbag_deployment text,
    mvc_form_airbag_deployment_status text,
    mvc_form_collision_indicators text,
    mvc_form_damage_location text,
    mvc_form_estimated_speed_kph integer,
    mvc_form_estimated_speed_mph integer,
    mvc_form_extrication_comments text,
    mvc_form_extrication_datetime timestamp without time zone,
    mvc_form_extrication_required_flag integer,
    mvc_form_patient_injured_flag integer,
    mvc_form_position_in_vehicle text,
    mvc_form_safety_devices text,
    mvc_form_seat_row_number text,
    mvc_form_vehicle_type text,
    mvc_form_weather text,
    pcr_additional_agencies text,
    pcr_transport_priority text,
    pcr_patient_acuity_initial text,
    pcr_patient_acuity_final text,
    unparsed_apd_incident_numbers text,
    apd_incident_numbers integer[],
    geometry public.geometry(Point,4326),
    austin_full_purpose boolean,
    location_id text,
    latitude double precision,
    longitude double precision,
    apd_incident_number_1 integer,
    apd_incident_number_2 integer,
    mvc_form_date date,
    mvc_form_time time without time zone
);


--
-- Name: COLUMN ems__incidents.pcr_key; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_key IS 'Unique identifier for the patient care record in the EMS Data Warehouse. Can be used to uniquely identify records in this dataset';


--
-- Name: COLUMN ems__incidents.incident_date_received; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_date_received IS 'The date that the incident was received by EMS. This could be the date that the EMS call taker took the call, or when it was transferred to EMS from another agency';


--
-- Name: COLUMN ems__incidents.incident_time_received; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_time_received IS 'The time that the incident was received by EMS. This could be the time that the EMS call taker took the call, or when it was transferred to EMS from another agency';


--
-- Name: COLUMN ems__incidents.incident_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_number IS 'Unique identifier for the Incident. Note that this value may not be unique to records in this dataset, as there may be multiple patient care records for a single incident';


--
-- Name: COLUMN ems__incidents.incident_location_address; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_location_address IS 'The street address for the location of the incident';


--
-- Name: COLUMN ems__incidents.incident_location_city; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_location_city IS 'The city in which the incident occurred';


--
-- Name: COLUMN ems__incidents.incident_location_state; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_location_state IS 'The state in which the incident occurred';


--
-- Name: COLUMN ems__incidents.incident_location_zip; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_location_zip IS 'The zip code in which the incident occurred';


--
-- Name: COLUMN ems__incidents.incident_location_longitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_location_longitude IS 'The longitude coordinate for the location of the incident';


--
-- Name: COLUMN ems__incidents.incident_location_latitude; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_location_latitude IS 'The latitude coordinate for the location of the incident';


--
-- Name: COLUMN ems__incidents.incident_problem; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_problem IS 'The ''call type'' or reason for the incident. Determined by communications staff while processing the 911 call.';


--
-- Name: COLUMN ems__incidents.incident_priority_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.incident_priority_number IS 'The ''priority'' of the incident. Determined by communications staff while processing the incident. Priority 1 is the highest priority, while 5 is the lowest priority';


--
-- Name: COLUMN ems__incidents.pcr_cause_of_injury; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_cause_of_injury IS 'A general description of the what caused the patient''s injury if applicable';


--
-- Name: COLUMN ems__incidents.pcr_patient_complaints; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_patient_complaints IS 'A general description of what the patient is complaining of (ex chest pain, difficulty breathing, etc)';


--
-- Name: COLUMN ems__incidents.pcr_provider_impression_primary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_provider_impression_primary IS 'The provider''s primary impression of the patient''s condition/injury/illness based on their assessment of the patient';


--
-- Name: COLUMN ems__incidents.pcr_provider_impression_secondary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_provider_impression_secondary IS 'The provider''s secondary or supporting impression of the patient''s condition/injury/illness based on their assessment of the patient';


--
-- Name: COLUMN ems__incidents.pcr_outcome; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_outcome IS 'A general description of the outcome of the patient encounter (ex Transported, Refused, Deceased)';


--
-- Name: COLUMN ems__incidents.pcr_transport_destination; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_transport_destination IS 'The facility that the patient was transported to, if applicable';


--
-- Name: COLUMN ems__incidents.pcr_patient_acuity_level_reason; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_patient_acuity_level_reason IS 'Indicates the primary reason a patient is determined to be ''High'' acuity, if applicable';


--
-- Name: COLUMN ems__incidents.pcr_patient_age; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_patient_age IS 'The patient''s age at the time of the encounter';


--
-- Name: COLUMN ems__incidents.pcr_patient_gender; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_patient_gender IS 'The patient''s gender';


--
-- Name: COLUMN ems__incidents.pcr_patient_race; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_patient_race IS 'The patient''s race';


--
-- Name: COLUMN ems__incidents.mvc_form_airbag_deployment; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_airbag_deployment IS 'Indicates which airbags were deployed (front, side, etc)';


--
-- Name: COLUMN ems__incidents.mvc_form_airbag_deployment_status; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_airbag_deployment_status IS 'Indicates whether airbags were deployed';


--
-- Name: COLUMN ems__incidents.mvc_form_collision_indicators; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_collision_indicators IS '? ';


--
-- Name: COLUMN ems__incidents.mvc_form_damage_location; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_damage_location IS 'Location of damage to the vehicle';


--
-- Name: COLUMN ems__incidents.mvc_form_estimated_speed_kph; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_estimated_speed_kph IS 'Estimated speed of the vehicle in kilometers per hour';


--
-- Name: COLUMN ems__incidents.mvc_form_estimated_speed_mph; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_estimated_speed_mph IS 'Estimated speed of the vehicle in miles per hour';


--
-- Name: COLUMN ems__incidents.mvc_form_extrication_comments; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_extrication_comments IS 'Provider notes about any extrication that was performed';


--
-- Name: COLUMN ems__incidents.mvc_form_extrication_datetime; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_extrication_datetime IS 'The time that an extrication was performed';


--
-- Name: COLUMN ems__incidents.mvc_form_extrication_required_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_extrication_required_flag IS 'Indicates whether the patient needed to be extricated from the vehicle (1 = yes, 0 = no)';


--
-- Name: COLUMN ems__incidents.mvc_form_patient_injured_flag; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_patient_injured_flag IS 'Indicates whether the patient was injured ( 1 = yes, 0 = no)';


--
-- Name: COLUMN ems__incidents.mvc_form_position_in_vehicle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_position_in_vehicle IS 'Where the patient was in the vehicle (front seat, second seat, etc)';


--
-- Name: COLUMN ems__incidents.mvc_form_safety_devices; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_safety_devices IS 'A list of any safety devices used, such as seatbelts or car seats';


--
-- Name: COLUMN ems__incidents.mvc_form_seat_row_number; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_seat_row_number IS '?';


--
-- Name: COLUMN ems__incidents.mvc_form_vehicle_type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_vehicle_type IS 'The type of vehicle involved in the accident (automobile, motorcycle, etc)';


--
-- Name: COLUMN ems__incidents.mvc_form_weather; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.mvc_form_weather IS 'A general description of weather conditions at the time of the accident';


--
-- Name: COLUMN ems__incidents.pcr_additional_agencies; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_additional_agencies IS 'A comma delimitted list of agencies that responded to this incident in addtion to EMS';


--
-- Name: COLUMN ems__incidents.pcr_transport_priority; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_transport_priority IS 'Code 1 is lower priority transport without lights and sirens. Code 3 is a higher priority transport with lights and sirens';


--
-- Name: COLUMN ems__incidents.pcr_patient_acuity_initial; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_patient_acuity_initial IS 'Initial patient acuity determined by provider';


--
-- Name: COLUMN ems__incidents.pcr_patient_acuity_final; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.pcr_patient_acuity_final IS 'Final patient acuity determined by provider';


--
-- Name: COLUMN ems__incidents.apd_incident_numbers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ems__incidents.apd_incident_numbers IS 'A comma delimitted list of incident numbers for APD incidents that are linked to the EMS incident. This field can be used to determin if there is an associated APD incident.';


--
-- Name: ems__incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ems__incidents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ems__incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ems__incidents_id_seq OWNED BY public.ems__incidents.id;


--
-- Name: engineering_areas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.engineering_areas (
    area_id integer NOT NULL,
    label text NOT NULL,
    geometry public.geometry(MultiPolygon,4326) NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: fatalities_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.fatalities_view AS
 SELECT people.id AS person_id,
    crashes.id AS crash_pk,
    crashes.cris_crash_id,
    crashes.record_locator,
    units.id AS unit_id,
    concat_ws(' '::text, people.prsn_first_name, people.prsn_mid_name, people.prsn_last_name) AS victim_name,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'yyyy'::text) AS year,
    concat_ws(' '::text, crashes.rpt_block_num, crashes.rpt_street_pfx, crashes.rpt_street_name, '(', crashes.rpt_sec_block_num, crashes.rpt_sec_street_pfx, crashes.rpt_sec_street_name, ')') AS location,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'YYYY-MM-DD'::text) AS crash_date_ct,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'HH24:MI:SS'::text) AS crash_time_ct,
    row_number() OVER (PARTITION BY (EXTRACT(year FROM (crashes.crash_timestamp AT TIME ZONE 'US/Central'::text))) ORDER BY ((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text))) AS ytd_fatality,
    dense_rank() OVER (PARTITION BY (EXTRACT(year FROM (crashes.crash_timestamp AT TIME ZONE 'US/Central'::text))) ORDER BY ((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text)), crashes.id) AS ytd_fatal_crash,
    crashes.case_id,
    crashes.law_enforcement_ytd_fatality_num,
    crashes.engineering_area_id
   FROM ((public.people
     LEFT JOIN public.units ON ((people.unit_id = units.id)))
     LEFT JOIN public.crashes ON ((units.crash_pk = crashes.id)))
  WHERE ((crashes.in_austin_full_purpose = true) AND (people.prsn_injry_sev_id = 4) AND (crashes.private_dr_fl = false) AND (crashes.is_deleted = false));


--
-- Name: intersection_road_map_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intersection_road_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intersections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intersections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_crashes_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.location_crashes_view AS
 SELECT crashes.cris_crash_id,
    'CR3'::text AS type,
    crashes.location_id,
    crashes.case_id,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'YYYY-MM-DD'::text) AS crash_date,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'HH24:MI:SS'::text) AS crash_time,
    upper(to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'dy'::text)) AS day_of_week,
    crash_injury_metrics_view.crash_injry_sev_id AS crash_sev_id,
    crashes.latitude,
    crashes.longitude,
    crashes.address_primary,
    crashes.address_secondary,
    crash_injury_metrics_view.non_injry_count,
    crash_injury_metrics_view.nonincap_injry_count,
    crash_injury_metrics_view.poss_injry_count,
    crash_injury_metrics_view.sus_serious_injry_count,
    crash_injury_metrics_view.tot_injry_count,
    crash_injury_metrics_view.unkn_injry_count,
    crash_injury_metrics_view.vz_fatality_count,
    crash_injury_metrics_view.est_comp_cost_crash_based,
    collsn.label AS collsn_desc,
    crash_units.movement_desc,
    crash_units.travel_direction,
    crash_units.veh_body_styl_desc,
    crash_units.veh_unit_desc
   FROM (((public.crashes
     LEFT JOIN LATERAL ( SELECT units.crash_pk,
            string_agg(movt.label, ','::text) AS movement_desc,
            string_agg(trvl_dir.label, ','::text) AS travel_direction,
            string_agg(veh_body_styl.label, ','::text) AS veh_body_styl_desc,
            string_agg(unit_desc.label, ','::text) AS veh_unit_desc
           FROM ((((public.units
             LEFT JOIN lookups.movt movt ON ((units.movement_id = movt.id)))
             LEFT JOIN lookups.trvl_dir trvl_dir ON ((units.veh_trvl_dir_id = trvl_dir.id)))
             LEFT JOIN lookups.veh_body_styl veh_body_styl ON ((units.veh_body_styl_id = veh_body_styl.id)))
             LEFT JOIN lookups.unit_desc unit_desc ON ((units.unit_desc_id = unit_desc.id)))
          WHERE (crashes.id = units.crash_pk)
          GROUP BY units.crash_pk) crash_units ON (true))
     LEFT JOIN LATERAL ( SELECT crash_injury_metrics_view_1.id,
            crash_injury_metrics_view_1.cris_crash_id,
            crash_injury_metrics_view_1.unkn_injry_count,
            crash_injury_metrics_view_1.nonincap_injry_count,
            crash_injury_metrics_view_1.poss_injry_count,
            crash_injury_metrics_view_1.non_injry_count,
            crash_injury_metrics_view_1.sus_serious_injry_count,
            crash_injury_metrics_view_1.tot_injry_count,
            crash_injury_metrics_view_1.fatality_count,
            crash_injury_metrics_view_1.vz_fatality_count,
            crash_injury_metrics_view_1.law_enf_fatality_count,
            crash_injury_metrics_view_1.cris_fatality_count,
            crash_injury_metrics_view_1.motor_vehicle_fatality_count,
            crash_injury_metrics_view_1.motor_vehicle_sus_serious_injry_count,
            crash_injury_metrics_view_1.motorcycle_fatality_count,
            crash_injury_metrics_view_1.motorcycle_sus_serious_count,
            crash_injury_metrics_view_1.bicycle_fatality_count,
            crash_injury_metrics_view_1.bicycle_sus_serious_injry_count,
            crash_injury_metrics_view_1.pedestrian_fatality_count,
            crash_injury_metrics_view_1.pedestrian_sus_serious_injry_count,
            crash_injury_metrics_view_1.micromobility_fatality_count,
            crash_injury_metrics_view_1.micromobility_sus_serious_injry_count,
            crash_injury_metrics_view_1.other_fatality_count,
            crash_injury_metrics_view_1.other_sus_serious_injry_count,
            crash_injury_metrics_view_1.crash_injry_sev_id,
            crash_injury_metrics_view_1.years_of_life_lost,
            crash_injury_metrics_view_1.est_comp_cost_crash_based,
            crash_injury_metrics_view_1.est_total_person_comp_cost
           FROM public.crash_injury_metrics_view crash_injury_metrics_view_1
          WHERE (crashes.id = crash_injury_metrics_view_1.id)
         LIMIT 1) crash_injury_metrics_view ON (true))
     LEFT JOIN lookups.collsn ON ((crashes.fhe_collsn_id = collsn.id)))
  WHERE ((crashes.is_deleted = false) AND (crashes.crash_timestamp >= ((now() - '5 years'::interval))::date))
UNION ALL
 SELECT aab.form_id AS cris_crash_id,
    'NON-CR3'::text AS type,
    aab.location_id,
    (aab.case_id)::text AS case_id,
    (aab.date)::text AS crash_date,
    concat(aab.hour, ':00:00') AS crash_time,
    ( SELECT
                CASE date_part('dow'::text, aab.date)
                    WHEN 0 THEN 'SUN'::text
                    WHEN 1 THEN 'MON'::text
                    WHEN 2 THEN 'TUE'::text
                    WHEN 3 THEN 'WED'::text
                    WHEN 4 THEN 'THU'::text
                    WHEN 5 THEN 'FRI'::text
                    WHEN 6 THEN 'SAT'::text
                    ELSE 'Unknown'::text
                END AS "case") AS day_of_week,
    0 AS crash_sev_id,
    aab.latitude,
    aab.longitude,
    aab.address AS address_primary,
    ''::text AS address_secondary,
    0 AS non_injry_count,
    0 AS nonincap_injry_count,
    0 AS poss_injry_count,
    0 AS sus_serious_injry_count,
    0 AS tot_injry_count,
    0 AS unkn_injry_count,
    0 AS vz_fatality_count,
    aab.est_comp_cost_crash_based,
    ''::text AS collsn_desc,
    ''::text AS movement_desc,
    ''::text AS travel_direction,
    ''::text AS veh_body_styl_desc,
    ''::text AS veh_unit_desc
   FROM public.atd_apd_blueform aab
  WHERE (aab.date >= ((now() - '5 years'::interval))::date);


--
-- Name: location_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.location_notes (
    date timestamp with time zone DEFAULT now() NOT NULL,
    user_email text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    text text NOT NULL,
    id integer NOT NULL,
    location_id text NOT NULL
);


--
-- Name: location_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.location_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: location_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.location_notes_id_seq OWNED BY public.location_notes.id;


--
-- Name: locations_list_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.locations_list_view AS
 WITH cr3_comp_costs AS (
         SELECT crashes_list_view.location_id,
            sum(crashes_list_view.est_comp_cost_crash_based) AS cr3_comp_costs_total
           FROM public.crashes_list_view
          WHERE (crashes_list_view.crash_timestamp > (now() - '5 years'::interval))
          GROUP BY crashes_list_view.location_id
        ), cr3_crash_counts AS (
         SELECT crashes.location_id,
            count(crashes.location_id) AS crash_count
           FROM public.crashes
          WHERE ((crashes.private_dr_fl = false) AND (crashes.location_id IS NOT NULL) AND (crashes.crash_timestamp > (now() - '5 years'::interval)))
          GROUP BY crashes.location_id
        ), non_cr3_crash_counts AS (
         SELECT atd_apd_blueform.location_id,
            count(atd_apd_blueform.location_id) AS crash_count,
            (count(atd_apd_blueform.location_id) * 10000) AS noncr3_comp_costs_total
           FROM public.atd_apd_blueform
          WHERE ((atd_apd_blueform.location_id IS NOT NULL) AND (atd_apd_blueform.date > (now() - '5 years'::interval)))
          GROUP BY atd_apd_blueform.location_id
        )
 SELECT locations.location_id,
    locations.description,
    locations.council_district,
    locations.location_group,
    COALESCE((cr3_comp_costs.cr3_comp_costs_total + non_cr3_crash_counts.noncr3_comp_costs_total), (0)::bigint) AS total_est_comp_cost,
    COALESCE(cr3_crash_counts.crash_count, (0)::bigint) AS cr3_crash_count,
    COALESCE(non_cr3_crash_counts.crash_count, (0)::bigint) AS non_cr3_crash_count,
    (COALESCE(cr3_crash_counts.crash_count, (0)::bigint) + COALESCE(non_cr3_crash_counts.crash_count, (0)::bigint)) AS crash_count
   FROM (((public.atd_txdot_locations locations
     LEFT JOIN cr3_crash_counts ON (((locations.location_id)::text = cr3_crash_counts.location_id)))
     LEFT JOIN non_cr3_crash_counts ON (((locations.location_id)::text = (non_cr3_crash_counts.location_id)::text)))
     LEFT JOIN cr3_comp_costs ON (((locations.location_id)::text = cr3_comp_costs.location_id)));


--
-- Name: non_coa_roadways; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_coa_roadways (
    id integer NOT NULL,
    geometry public.geometry(MultiPolygon,4326) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE non_coa_roadways; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.non_coa_roadways IS 'Polygon layer which represents roadways that are not maintained by the City of Austin';


--
-- Name: non_coa_roadways_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_coa_roadways_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_coa_roadways_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.non_coa_roadways_id_seq OWNED BY public.non_coa_roadways.id;


--
-- Name: non_cr3_mainlane_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.non_cr3_mainlane_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: non_cr3_mainlanes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.non_cr3_mainlanes (
    gid integer DEFAULT nextval('public.non_cr3_mainlane_gid_seq'::regclass) NOT NULL,
    __gid bigint,
    fid numeric,
    objectid_1 numeric,
    objectid numeric,
    segmentid numeric,
    l_state character varying(80),
    r_state character varying(80),
    l_county character varying(80),
    r_county character varying(80),
    lf_addr numeric,
    lt_addr numeric,
    rf_addr numeric,
    rt_addr numeric,
    l_parity character varying(80),
    r_parity character varying(80),
    l_post_com character varying(80),
    r_post_com character varying(80),
    l_zip character varying(80),
    r_zip character varying(80),
    pre_dir character varying(80),
    st_name character varying(80),
    st_type character varying(80),
    post_dir character varying(80),
    full_name character varying(80),
    st_alias character varying(80),
    one_way character varying(80),
    sp_limit numeric,
    rdcls_typ character varying(80),
    shape_leng numeric,
    shape__len numeric,
    geometry public.geometry(MultiLineString,4326)
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.crash_notes.id;


--
-- Name: people_cris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.people_cris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_cris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.people_cris_id_seq OWNED BY public.people_cris.id;


--
-- Name: people_edits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.people_edits (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    drvr_city_name text,
    drvr_drg_cat_1_id integer,
    drvr_zip text,
    ems_id integer,
    is_deleted boolean,
    is_primary_person boolean,
    prsn_age integer,
    prsn_alc_rslt_id integer,
    prsn_alc_spec_type_id integer,
    prsn_bac_test_rslt text,
    prsn_death_timestamp timestamp with time zone,
    prsn_drg_rslt_id integer,
    prsn_drg_spec_type_id integer,
    prsn_ethnicity_id integer,
    prsn_exp_homelessness boolean,
    prsn_first_name text,
    prsn_gndr_id integer,
    prsn_helmet_id integer,
    prsn_injry_sev_id integer,
    prsn_last_name text,
    prsn_mid_name text,
    prsn_name_sfx text,
    prsn_nbr integer,
    prsn_occpnt_pos_id integer,
    prsn_rest_id integer,
    prsn_taken_by text,
    prsn_taken_to text,
    prsn_type_id integer,
    unit_id integer,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    drvr_lic_type_id integer
);


--
-- Name: COLUMN people_edits.drvr_lic_type_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.people_edits.drvr_lic_type_id IS 'Driver''s license type';


--
-- Name: people_list_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.people_list_view AS
 SELECT people.id,
    people.created_at,
    people.created_by,
    people.drvr_city_name,
    people.drvr_drg_cat_1_id,
    people.drvr_zip,
    people.ems_id,
    people.est_comp_cost_crash_based,
    people.is_deleted,
    people.is_primary_person,
    people.prsn_age,
    people.prsn_alc_rslt_id,
    people.prsn_alc_spec_type_id,
    people.prsn_bac_test_rslt,
    people.prsn_death_timestamp,
    people.prsn_drg_rslt_id,
    people.prsn_drg_spec_type_id,
    people.prsn_ethnicity_id,
    people.prsn_exp_homelessness,
    people.prsn_first_name,
    people.prsn_gndr_id,
    people.prsn_helmet_id,
    people.prsn_injry_sev_id,
    people.prsn_last_name,
    people.prsn_mid_name,
    people.prsn_name_sfx,
    people.prsn_nbr,
    people.prsn_occpnt_pos_id,
    people.prsn_rest_id,
    people.prsn_taken_by,
    people.prsn_taken_to,
    people.prsn_type_id,
    people.unit_id,
    people.updated_at,
    people.updated_by,
    people.years_of_life_lost,
    crashes.id AS crash_pk,
    crashes.cris_crash_id,
    crashes.crash_timestamp,
    injry_sev.label AS prsn_injry_sev_desc,
    units.unit_nbr,
    units.unit_desc_id,
    mode_category.label AS mode_desc
   FROM (((((public.people
     LEFT JOIN public.units units ON ((people.unit_id = units.id)))
     LEFT JOIN public.people_cris people_cris ON ((people.id = people_cris.id)))
     LEFT JOIN public.crashes crashes ON ((units.crash_pk = crashes.id)))
     LEFT JOIN lookups.injry_sev ON ((injry_sev.id = people.prsn_injry_sev_id)))
     LEFT JOIN lookups.mode_category ON ((units.vz_mode_category_id = mode_category.id)));


--
-- Name: polygons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.polygons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations (
    id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    recommendation_status_id integer,
    rec_text text,
    created_by text NOT NULL,
    rec_update text,
    crash_pk integer NOT NULL
);


--
-- Name: recommendations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendations_id_seq OWNED BY public.recommendations.id;


--
-- Name: recommendations_partners; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recommendations_partners (
    id integer NOT NULL,
    recommendation_id integer,
    partner_id integer
);


--
-- Name: recommendations_partners_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recommendations_partners_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recommendations_partners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recommendations_partners_id_seq OWNED BY public.recommendations_partners.id;


--
-- Name: socrata_export_crashes_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.socrata_export_crashes_view AS
 WITH unit_aggregates AS (
         SELECT crashes_1.id,
            string_agg(DISTINCT mode_categories.label, ' & '::text) AS units_involved
           FROM ((public.crashes crashes_1
             LEFT JOIN public.units ON ((crashes_1.id = units.crash_pk)))
             LEFT JOIN lookups.mode_category mode_categories ON ((units.vz_mode_category_id = mode_categories.id)))
          GROUP BY crashes_1.id
        )
 SELECT crashes.id,
    crashes.cris_crash_id,
    crashes.case_id,
    crashes.address_primary,
    crashes.address_secondary,
    crashes.is_deleted,
    crashes.latitude,
    crashes.longitude,
    crashes.rpt_block_num,
    crashes.rpt_street_name,
    crashes.rpt_street_sfx,
    crashes.crash_speed_limit,
    crashes.road_constr_zone_fl,
    crashes.is_temp_record,
    cimv.crash_injry_sev_id AS crash_sev_id,
    cimv.sus_serious_injry_count AS sus_serious_injry_cnt,
    cimv.nonincap_injry_count AS nonincap_injry_cnt,
    cimv.poss_injry_count AS poss_injry_cnt,
    cimv.non_injry_count AS non_injry_cnt,
    cimv.unkn_injry_count AS unkn_injry_cnt,
    cimv.tot_injry_count AS tot_injry_cnt,
    cimv.law_enf_fatality_count,
    cimv.vz_fatality_count AS death_cnt,
    crashes.onsys_fl,
    crashes.private_dr_fl,
    unit_aggregates.units_involved,
    cimv.motor_vehicle_fatality_count AS motor_vehicle_death_count,
    cimv.motor_vehicle_sus_serious_injry_count AS motor_vehicle_serious_injury_count,
    cimv.bicycle_fatality_count AS bicycle_death_count,
    cimv.bicycle_sus_serious_injry_count AS bicycle_serious_injury_count,
    cimv.pedestrian_fatality_count AS pedestrian_death_count,
    cimv.pedestrian_sus_serious_injry_count AS pedestrian_serious_injury_count,
    cimv.motorcycle_fatality_count AS motorcycle_death_count,
    cimv.motorcycle_sus_serious_count AS motorcycle_serious_injury_count,
    cimv.micromobility_fatality_count AS micromobility_death_count,
    cimv.micromobility_sus_serious_injry_count AS micromobility_serious_injury_count,
    cimv.other_fatality_count AS other_death_count,
    cimv.other_sus_serious_injry_count AS other_serious_injury_count,
    cimv.years_of_life_lost,
    to_char(crashes.crash_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS'::text) AS crash_timestamp,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'YYYY-MM-DD"T"HH24:MI:SS'::text) AS crash_timestamp_ct,
        CASE
            WHEN ((crashes.latitude IS NOT NULL) AND (crashes.longitude IS NOT NULL)) THEN (((('POINT ('::text || (crashes.longitude)::text) || ' '::text) || (crashes.latitude)::text) || ')'::text)
            ELSE NULL::text
        END AS point,
    COALESCE((cimv.crash_injry_sev_id = 4), false) AS crash_fatal_fl
   FROM ((public.crashes
     LEFT JOIN LATERAL ( SELECT crash_injury_metrics_view.id,
            crash_injury_metrics_view.cris_crash_id,
            crash_injury_metrics_view.unkn_injry_count,
            crash_injury_metrics_view.nonincap_injry_count,
            crash_injury_metrics_view.poss_injry_count,
            crash_injury_metrics_view.non_injry_count,
            crash_injury_metrics_view.sus_serious_injry_count,
            crash_injury_metrics_view.tot_injry_count,
            crash_injury_metrics_view.fatality_count,
            crash_injury_metrics_view.vz_fatality_count,
            crash_injury_metrics_view.law_enf_fatality_count,
            crash_injury_metrics_view.cris_fatality_count,
            crash_injury_metrics_view.motor_vehicle_fatality_count,
            crash_injury_metrics_view.motor_vehicle_sus_serious_injry_count,
            crash_injury_metrics_view.motorcycle_fatality_count,
            crash_injury_metrics_view.motorcycle_sus_serious_count,
            crash_injury_metrics_view.bicycle_fatality_count,
            crash_injury_metrics_view.bicycle_sus_serious_injry_count,
            crash_injury_metrics_view.pedestrian_fatality_count,
            crash_injury_metrics_view.pedestrian_sus_serious_injry_count,
            crash_injury_metrics_view.micromobility_fatality_count,
            crash_injury_metrics_view.micromobility_sus_serious_injry_count,
            crash_injury_metrics_view.other_fatality_count,
            crash_injury_metrics_view.other_sus_serious_injry_count,
            crash_injury_metrics_view.crash_injry_sev_id,
            crash_injury_metrics_view.years_of_life_lost,
            crash_injury_metrics_view.est_comp_cost_crash_based,
            crash_injury_metrics_view.est_total_person_comp_cost
           FROM public.crash_injury_metrics_view
          WHERE (crashes.id = crash_injury_metrics_view.id)
         LIMIT 1) cimv ON (true))
     LEFT JOIN LATERAL ( SELECT unit_aggregates_1.id,
            unit_aggregates_1.units_involved
           FROM unit_aggregates unit_aggregates_1
          WHERE (crashes.id = unit_aggregates_1.id)
         LIMIT 1) unit_aggregates ON (true))
  WHERE ((crashes.is_deleted = false) AND (crashes.in_austin_full_purpose = true) AND (crashes.private_dr_fl = false) AND (crashes.crash_timestamp < (now() - '14 days'::interval)))
  ORDER BY crashes.id;


--
-- Name: socrata_export_people_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.socrata_export_people_view AS
 SELECT people.id,
    people.unit_id,
    crashes.id AS crash_pk,
    crashes.cris_crash_id,
    crashes.is_temp_record,
    people.is_deleted,
    people.is_primary_person,
    people.prsn_age,
    people.prsn_gndr_id AS prsn_sex_id,
    gndr.label AS prsn_sex_label,
    people.prsn_ethnicity_id,
    drvr_ethncty.label AS prsn_ethnicity_label,
    people.prsn_injry_sev_id,
    units.vz_mode_category_id AS mode_id,
    mode_categories.label AS mode_desc,
    to_char(crashes.crash_timestamp, 'YYYY-MM-DD"T"HH24:MI:SS'::text) AS crash_timestamp,
    to_char((crashes.crash_timestamp AT TIME ZONE 'US/Central'::text), 'YYYY-MM-DD"T"HH24:MI:SS'::text) AS crash_timestamp_ct
   FROM (((((public.people
     LEFT JOIN public.units units ON ((people.unit_id = units.id)))
     LEFT JOIN public.crashes crashes ON ((units.crash_pk = crashes.id)))
     LEFT JOIN lookups.mode_category mode_categories ON ((units.vz_mode_category_id = mode_categories.id)))
     LEFT JOIN lookups.drvr_ethncty ON ((people.prsn_ethnicity_id = drvr_ethncty.id)))
     LEFT JOIN lookups.gndr ON ((people.prsn_gndr_id = gndr.id)))
  WHERE ((people.is_deleted = false) AND (crashes.in_austin_full_purpose = true) AND (crashes.private_dr_fl = false) AND (crashes.is_deleted = false) AND (crashes.crash_timestamp < (now() - '14 days'::interval)) AND ((people.prsn_injry_sev_id = 1) OR (people.prsn_injry_sev_id = 4)));


--
-- Name: unit_injury_metrics_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.unit_injury_metrics_view AS
SELECT
    NULL::integer AS id,
    NULL::integer AS crash_pk,
    NULL::bigint AS unkn_injry_count,
    NULL::bigint AS nonincap_injry_count,
    NULL::bigint AS poss_injry_count,
    NULL::bigint AS non_injry_count,
    NULL::bigint AS sus_serious_injry_count,
    NULL::bigint AS fatality_count,
    NULL::bigint AS vz_fatality_count,
    NULL::bigint AS law_enf_fatality_count,
    NULL::bigint AS cris_fatality_count,
    NULL::bigint AS years_of_life_lost;


--
-- Name: units_cris; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units_cris (
    id integer NOT NULL,
    autonomous_unit_id integer,
    contrib_factr_1_id integer,
    contrib_factr_2_id integer,
    contrib_factr_3_id integer,
    contrib_factr_p1_id integer,
    contrib_factr_p2_id integer,
    crash_pk integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer,
    cris_schema_version text NOT NULL,
    e_scooter_id integer,
    first_harm_evt_inv_id integer,
    is_deleted boolean DEFAULT false NOT NULL,
    pbcat_pedalcyclist_id integer,
    pbcat_pedestrian_id integer,
    pedalcyclist_action_id integer,
    pedestrian_action_id integer,
    rpt_autonomous_level_engaged_id integer,
    unit_desc_id integer,
    unit_nbr integer NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    veh_body_styl_id integer,
    veh_damage_description1_id integer,
    veh_damage_description2_id integer,
    veh_damage_direction_of_force1_id integer,
    veh_damage_direction_of_force2_id integer,
    veh_damage_severity1_id integer,
    veh_damage_severity2_id integer,
    veh_make_id integer,
    veh_mod_id integer,
    veh_mod_year integer,
    veh_trvl_dir_id integer,
    vin text,
    veh_hnr_fl boolean,
    CONSTRAINT units_cris_unit_desc_id_check CHECK (((unit_desc_id < 177) OR ((created_by <> 'cris'::text) AND (created_by <> 'system'::text)))),
    CONSTRAINT units_cris_veh_body_styl_id_check CHECK ((veh_body_styl_id < 177))
);


--
-- Name: COLUMN units_cris.veh_hnr_fl; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.units_cris.veh_hnr_fl IS 'If the unit was involved in a hit-and-run crash. This field may indicate that the unit was the victim of a hit and run, or this unit left the scene/committed the hit and run';


--
-- Name: units_cris_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.units_cris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: units_cris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.units_cris_id_seq OWNED BY public.units_cris.id;


--
-- Name: units_edits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.units_edits (
    id integer NOT NULL,
    autonomous_unit_id integer,
    contrib_factr_1_id integer,
    contrib_factr_2_id integer,
    contrib_factr_3_id integer,
    contrib_factr_p1_id integer,
    contrib_factr_p2_id integer,
    crash_pk integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text DEFAULT 'system'::text NOT NULL,
    cris_crash_id integer,
    e_scooter_id integer,
    first_harm_evt_inv_id integer,
    is_deleted boolean,
    movement_id integer,
    pbcat_pedalcyclist_id integer,
    pbcat_pedestrian_id integer,
    pedalcyclist_action_id integer,
    pedestrian_action_id integer,
    rpt_autonomous_level_engaged_id integer,
    unit_desc_id integer,
    unit_nbr integer,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by text DEFAULT 'system'::text NOT NULL,
    veh_body_styl_id integer,
    veh_damage_description1_id integer,
    veh_damage_description2_id integer,
    veh_damage_direction_of_force1_id integer,
    veh_damage_direction_of_force2_id integer,
    veh_damage_severity1_id integer,
    veh_damage_severity2_id integer,
    veh_make_id integer,
    veh_mod_id integer,
    veh_mod_year integer,
    veh_trvl_dir_id integer,
    vin text,
    veh_hnr_fl boolean
);


--
-- Name: COLUMN units_edits.veh_hnr_fl; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.units_edits.veh_hnr_fl IS 'If the unit was involved in a hit-and-run crash. This field may indicate that the unit was the victim of a hit and run, or this unit left the scene/committed the hit and run';


--
-- Name: view_crash_narratives_ocr_todo; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.view_crash_narratives_ocr_todo AS
 SELECT crashes.id,
    crashes.cris_crash_id
   FROM public.crashes
  WHERE ((crashes.cr3_stored_fl = true) AND (crashes.investigator_narrative IS NULL) AND ((crashes.investigator_narrative_ocr_processed_at IS NULL) OR (crashes.cr3_processed_at >= crashes.investigator_narrative_ocr_processed_at)) AND (crashes.updated_at > '2024-09-01 00:00:00+00'::timestamp with time zone))
  ORDER BY crashes.cr3_processed_at, crashes.id;


--
-- Name: VIEW view_crash_narratives_ocr_todo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.view_crash_narratives_ocr_todo IS 'View which lists crashes which need to 
be processed by the OCR narrative extraction ETL';


--
-- Name: _column_metadata id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._column_metadata ALTER COLUMN id SET DEFAULT nextval('public._column_metadata_id_seq'::regclass);


--
-- Name: _cris_import_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cris_import_log ALTER COLUMN id SET DEFAULT nextval('public.cris_import_log_id_seq'::regclass);


--
-- Name: afd__incidents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.afd__incidents ALTER COLUMN id SET DEFAULT nextval('public.afd__incidents_id_seq1'::regclass);


--
-- Name: atd__coordination_partners_lkp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd__coordination_partners_lkp ALTER COLUMN id SET DEFAULT nextval('public.atd__coordination_partners_lkp_id_seq'::regclass);


--
-- Name: atd__recommendation_status_lkp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd__recommendation_status_lkp ALTER COLUMN id SET DEFAULT nextval('public.atd__recommendation_status_lkp_id_seq'::regclass);


--
-- Name: atd_apd_blueform form_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd_apd_blueform ALTER COLUMN form_id SET DEFAULT nextval('public.atd_apd_blueform_form_id_seq'::regclass);


--
-- Name: atd_jurisdictions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd_jurisdictions ALTER COLUMN id SET DEFAULT nextval('public.atd_jurisdictions_id_seq'::regclass);


--
-- Name: change_log_crashes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes ALTER COLUMN id SET DEFAULT nextval('public.change_log_crashes_id_seq'::regclass);


--
-- Name: change_log_crashes_cris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes_cris ALTER COLUMN id SET DEFAULT nextval('public.change_log_crashes_cris_id_seq'::regclass);


--
-- Name: change_log_crashes_edits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes_edits ALTER COLUMN id SET DEFAULT nextval('public.change_log_crashes_edits_id_seq'::regclass);


--
-- Name: change_log_people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people ALTER COLUMN id SET DEFAULT nextval('public.change_log_people_id_seq'::regclass);


--
-- Name: change_log_people_cris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people_cris ALTER COLUMN id SET DEFAULT nextval('public.change_log_people_cris_id_seq'::regclass);


--
-- Name: change_log_people_edits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people_edits ALTER COLUMN id SET DEFAULT nextval('public.change_log_people_edits_id_seq'::regclass);


--
-- Name: change_log_units id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units ALTER COLUMN id SET DEFAULT nextval('public.change_log_units_id_seq'::regclass);


--
-- Name: change_log_units_cris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units_cris ALTER COLUMN id SET DEFAULT nextval('public.change_log_units_cris_id_seq'::regclass);


--
-- Name: change_log_units_edits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units_edits ALTER COLUMN id SET DEFAULT nextval('public.change_log_units_edits_id_seq'::regclass);


--
-- Name: charges_cris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges_cris ALTER COLUMN id SET DEFAULT nextval('public.charges_cris_id_seq'::regclass);


--
-- Name: council_districts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.council_districts ALTER COLUMN id SET DEFAULT nextval('public.council_districts_id_seq'::regclass);


--
-- Name: crash_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crash_notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: crashes_cris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris ALTER COLUMN id SET DEFAULT nextval('public.crashes_cris_id_seq'::regclass);


--
-- Name: ems__incidents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ems__incidents ALTER COLUMN id SET DEFAULT nextval('public.ems__incidents_id_seq'::regclass);


--
-- Name: location_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_notes ALTER COLUMN id SET DEFAULT nextval('public.location_notes_id_seq'::regclass);


--
-- Name: non_coa_roadways id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_coa_roadways ALTER COLUMN id SET DEFAULT nextval('public.non_coa_roadways_id_seq'::regclass);


--
-- Name: people_cris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris ALTER COLUMN id SET DEFAULT nextval('public.people_cris_id_seq'::regclass);


--
-- Name: recommendations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations ALTER COLUMN id SET DEFAULT nextval('public.recommendations_id_seq'::regclass);


--
-- Name: recommendations_partners id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations_partners ALTER COLUMN id SET DEFAULT nextval('public.recommendations_partners_id_seq'::regclass);


--
-- Name: units_cris id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris ALTER COLUMN id SET DEFAULT nextval('public.units_cris_id_seq'::regclass);


--
-- Name: agency agency_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.agency
    ADD CONSTRAINT agency_pkey PRIMARY KEY (id);


--
-- Name: autonomous_level_engaged autonomous_level_engaged_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.autonomous_level_engaged
    ADD CONSTRAINT autonomous_level_engaged_pkey PRIMARY KEY (id);


--
-- Name: autonomous_unit autonomous_unit_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.autonomous_unit
    ADD CONSTRAINT autonomous_unit_pkey PRIMARY KEY (id);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (id);


--
-- Name: cnty cnty_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.cnty
    ADD CONSTRAINT cnty_pkey PRIMARY KEY (id);


--
-- Name: collsn collsn_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.collsn
    ADD CONSTRAINT collsn_pkey PRIMARY KEY (id);


--
-- Name: contrib_factr contrib_factr_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.contrib_factr
    ADD CONSTRAINT contrib_factr_pkey PRIMARY KEY (id);


--
-- Name: drvr_ethncty drvr_ethncty_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.drvr_ethncty
    ADD CONSTRAINT drvr_ethncty_pkey PRIMARY KEY (id);


--
-- Name: drvr_lic_type drvr_lic_type_label_key; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.drvr_lic_type
    ADD CONSTRAINT drvr_lic_type_label_key UNIQUE (label);


--
-- Name: drvr_lic_type drvr_lic_type_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.drvr_lic_type
    ADD CONSTRAINT drvr_lic_type_pkey PRIMARY KEY (id);


--
-- Name: e_scooter e_scooter_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.e_scooter
    ADD CONSTRAINT e_scooter_pkey PRIMARY KEY (id);


--
-- Name: gndr gndr_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.gndr
    ADD CONSTRAINT gndr_pkey PRIMARY KEY (id);


--
-- Name: harm_evnt harm_evnt_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.harm_evnt
    ADD CONSTRAINT harm_evnt_pkey PRIMARY KEY (id);


--
-- Name: helmet helmet_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.helmet
    ADD CONSTRAINT helmet_pkey PRIMARY KEY (id);


--
-- Name: injry_sev injry_sev_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.injry_sev
    ADD CONSTRAINT injry_sev_pkey PRIMARY KEY (id);


--
-- Name: intrsct_relat intrsct_relat_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.intrsct_relat
    ADD CONSTRAINT intrsct_relat_pkey PRIMARY KEY (id);


--
-- Name: light_cond light_cond_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.light_cond
    ADD CONSTRAINT light_cond_pkey PRIMARY KEY (id);


--
-- Name: mode_category mode_category_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.mode_category
    ADD CONSTRAINT mode_category_pkey PRIMARY KEY (id);


--
-- Name: movt movt_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.movt
    ADD CONSTRAINT movt_pkey PRIMARY KEY (id);


--
-- Name: obj_struck obj_struck_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.obj_struck
    ADD CONSTRAINT obj_struck_pkey PRIMARY KEY (id);


--
-- Name: occpnt_pos occpnt_pos_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.occpnt_pos
    ADD CONSTRAINT occpnt_pos_pkey PRIMARY KEY (id);


--
-- Name: pbcat_pedalcyclist pbcat_pedalcyclist_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.pbcat_pedalcyclist
    ADD CONSTRAINT pbcat_pedalcyclist_pkey PRIMARY KEY (id);


--
-- Name: pbcat_pedestrian pbcat_pedestrian_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.pbcat_pedestrian
    ADD CONSTRAINT pbcat_pedestrian_pkey PRIMARY KEY (id);


--
-- Name: pedalcyclist_action pedalcyclist_action_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.pedalcyclist_action
    ADD CONSTRAINT pedalcyclist_action_pkey PRIMARY KEY (id);


--
-- Name: pedestrian_action pedestrian_action_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.pedestrian_action
    ADD CONSTRAINT pedestrian_action_pkey PRIMARY KEY (id);


--
-- Name: prsn_type prsn_type_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.prsn_type
    ADD CONSTRAINT prsn_type_pkey PRIMARY KEY (id);


--
-- Name: rest rest_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.rest
    ADD CONSTRAINT rest_pkey PRIMARY KEY (id);


--
-- Name: road_part road_part_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.road_part
    ADD CONSTRAINT road_part_pkey PRIMARY KEY (id);


--
-- Name: rwy_sys rwy_sys_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.rwy_sys
    ADD CONSTRAINT rwy_sys_pkey PRIMARY KEY (id);


--
-- Name: specimen_type specimen_type_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.specimen_type
    ADD CONSTRAINT specimen_type_pkey PRIMARY KEY (id);


--
-- Name: substnc_cat substnc_cat_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.substnc_cat
    ADD CONSTRAINT substnc_cat_pkey PRIMARY KEY (id);


--
-- Name: substnc_tst_result substnc_tst_result_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.substnc_tst_result
    ADD CONSTRAINT substnc_tst_result_pkey PRIMARY KEY (id);


--
-- Name: surf_cond surf_cond_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.surf_cond
    ADD CONSTRAINT surf_cond_pkey PRIMARY KEY (id);


--
-- Name: surf_type surf_type_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.surf_type
    ADD CONSTRAINT surf_type_pkey PRIMARY KEY (id);


--
-- Name: traffic_cntl traffic_cntl_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.traffic_cntl
    ADD CONSTRAINT traffic_cntl_pkey PRIMARY KEY (id);


--
-- Name: trvl_dir trvl_dir_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.trvl_dir
    ADD CONSTRAINT trvl_dir_pkey PRIMARY KEY (id);


--
-- Name: unit_desc unit_desc_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.unit_desc
    ADD CONSTRAINT unit_desc_pkey PRIMARY KEY (id);


--
-- Name: veh_body_styl veh_body_styl_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.veh_body_styl
    ADD CONSTRAINT veh_body_styl_pkey PRIMARY KEY (id);


--
-- Name: veh_damage_description veh_damage_description_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.veh_damage_description
    ADD CONSTRAINT veh_damage_description_pkey PRIMARY KEY (id);


--
-- Name: veh_damage_severity veh_damage_severity_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.veh_damage_severity
    ADD CONSTRAINT veh_damage_severity_pkey PRIMARY KEY (id);


--
-- Name: veh_direction_of_force veh_direction_of_force_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.veh_direction_of_force
    ADD CONSTRAINT veh_direction_of_force_pkey PRIMARY KEY (id);


--
-- Name: veh_make veh_make_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.veh_make
    ADD CONSTRAINT veh_make_pkey PRIMARY KEY (id);


--
-- Name: veh_mod veh_mod_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.veh_mod
    ADD CONSTRAINT veh_mod_pkey PRIMARY KEY (id);


--
-- Name: wthr_cond wthr_cond_pkey; Type: CONSTRAINT; Schema: lookups; Owner: -
--

ALTER TABLE ONLY lookups.wthr_cond
    ADD CONSTRAINT wthr_cond_pkey PRIMARY KEY (id);


--
-- Name: _column_metadata _column_metadata_column_name_record_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._column_metadata
    ADD CONSTRAINT _column_metadata_column_name_record_type_key UNIQUE (column_name, record_type);


--
-- Name: _column_metadata _column_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._column_metadata
    ADD CONSTRAINT _column_metadata_pkey PRIMARY KEY (id);


--
-- Name: afd__incidents afd__incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.afd__incidents
    ADD CONSTRAINT afd__incidents_pkey PRIMARY KEY (id);


--
-- Name: atd__coordination_partners_lkp atd__coordination_partners_lkp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd__coordination_partners_lkp
    ADD CONSTRAINT atd__coordination_partners_lkp_pkey PRIMARY KEY (id);


--
-- Name: atd__recommendation_status_lkp atd__recommendation_status_lkp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd__recommendation_status_lkp
    ADD CONSTRAINT atd__recommendation_status_lkp_pkey PRIMARY KEY (id);


--
-- Name: atd_apd_blueform atd_apd_blueform_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd_apd_blueform
    ADD CONSTRAINT atd_apd_blueform_pk PRIMARY KEY (case_id);


--
-- Name: atd_txdot_locations atd_txdot_locations_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd_txdot_locations
    ADD CONSTRAINT atd_txdot_locations_pk PRIMARY KEY (location_id);


--
-- Name: atd_txdot_locations atd_txdot_locations_unique_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd_txdot_locations
    ADD CONSTRAINT atd_txdot_locations_unique_id_key UNIQUE (location_id);


--
-- Name: change_log_crashes_cris change_log_crashes_cris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes_cris
    ADD CONSTRAINT change_log_crashes_cris_pkey PRIMARY KEY (id);


--
-- Name: change_log_crashes_edits change_log_crashes_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes_edits
    ADD CONSTRAINT change_log_crashes_edits_pkey PRIMARY KEY (id);


--
-- Name: change_log_crashes change_log_crashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes
    ADD CONSTRAINT change_log_crashes_pkey PRIMARY KEY (id);


--
-- Name: change_log_people_cris change_log_people_cris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people_cris
    ADD CONSTRAINT change_log_people_cris_pkey PRIMARY KEY (id);


--
-- Name: change_log_people_edits change_log_people_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people_edits
    ADD CONSTRAINT change_log_people_edits_pkey PRIMARY KEY (id);


--
-- Name: change_log_people change_log_people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people
    ADD CONSTRAINT change_log_people_pkey PRIMARY KEY (id);


--
-- Name: change_log_units_cris change_log_units_cris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units_cris
    ADD CONSTRAINT change_log_units_cris_pkey PRIMARY KEY (id);


--
-- Name: change_log_units_edits change_log_units_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units_edits
    ADD CONSTRAINT change_log_units_edits_pkey PRIMARY KEY (id);


--
-- Name: change_log_units change_log_units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units
    ADD CONSTRAINT change_log_units_pkey PRIMARY KEY (id);


--
-- Name: charges_cris charges_cris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges_cris
    ADD CONSTRAINT charges_cris_pkey PRIMARY KEY (id);


--
-- Name: council_districts council_districts_council_district_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.council_districts
    ADD CONSTRAINT council_districts_council_district_key UNIQUE (council_district);


--
-- Name: council_districts council_districts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.council_districts
    ADD CONSTRAINT council_districts_pkey PRIMARY KEY (id);


--
-- Name: crashes crashes_cris_crash_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_cris_crash_id_key UNIQUE (cris_crash_id);


--
-- Name: crashes_cris crashes_cris_cris_crash_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_cris_crash_id_key UNIQUE (cris_crash_id);


--
-- Name: crashes_cris crashes_cris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_pkey PRIMARY KEY (id);


--
-- Name: crashes_edits crashes_edits_cris_crash_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_cris_crash_id_key UNIQUE (cris_crash_id);


--
-- Name: crashes_edits crashes_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_pkey PRIMARY KEY (id);


--
-- Name: crashes crashes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_pkey PRIMARY KEY (id);


--
-- Name: crashes crashes_record_locator_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_record_locator_key UNIQUE (record_locator);


--
-- Name: _cris_import_log cris_import_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public._cris_import_log
    ADD CONSTRAINT cris_import_log_pkey PRIMARY KEY (id);


--
-- Name: ems__incidents ems__incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ems__incidents
    ADD CONSTRAINT ems__incidents_pkey PRIMARY KEY (id);


--
-- Name: engineering_areas engineering_areas_label_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.engineering_areas
    ADD CONSTRAINT engineering_areas_label_key UNIQUE (label);


--
-- Name: engineering_areas engineering_areas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.engineering_areas
    ADD CONSTRAINT engineering_areas_pkey PRIMARY KEY (area_id);


--
-- Name: atd_jurisdictions jurisdictions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.atd_jurisdictions
    ADD CONSTRAINT jurisdictions_pkey PRIMARY KEY (id);


--
-- Name: location_notes location_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_notes
    ADD CONSTRAINT location_notes_pkey PRIMARY KEY (id);


--
-- Name: non_coa_roadways non_coa_roadways_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_coa_roadways
    ADD CONSTRAINT non_coa_roadways_pkey PRIMARY KEY (id);


--
-- Name: non_cr3_mainlanes non_cr3_mainlane_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.non_cr3_mainlanes
    ADD CONSTRAINT non_cr3_mainlane_pkey PRIMARY KEY (gid);


--
-- Name: crash_notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crash_notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: people_cris people_cris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_pkey PRIMARY KEY (id);


--
-- Name: people_edits people_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_crash_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_crash_id_key UNIQUE (crash_pk);


--
-- Name: recommendations_partners recommendations_partners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations_partners
    ADD CONSTRAINT recommendations_partners_pkey PRIMARY KEY (id);


--
-- Name: recommendations recommendations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_pkey PRIMARY KEY (id);


--
-- Name: people unique_people; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT unique_people UNIQUE (unit_id, prsn_nbr) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: people_cris unique_people_cris; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT unique_people_cris UNIQUE (unit_id, prsn_nbr);


--
-- Name: people_edits unique_people_edits; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT unique_people_edits UNIQUE (unit_id, prsn_nbr);


--
-- Name: units unique_units; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT unique_units UNIQUE (crash_pk, unit_nbr) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: units_cris unique_units_cris; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT unique_units_cris UNIQUE (crash_pk, unit_nbr);


--
-- Name: units_cris units_cris_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_pkey PRIMARY KEY (id);


--
-- Name: units_edits units_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_pkey PRIMARY KEY (id);


--
-- Name: units units_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);


--
-- Name: atd_apd_blueform_date_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_apd_blueform_date_index ON public.atd_apd_blueform USING btree (date);


--
-- Name: atd_apd_blueform_form_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_apd_blueform_form_id_index ON public.atd_apd_blueform USING btree (form_id);


--
-- Name: atd_apd_blueform_hour_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_apd_blueform_hour_index ON public.atd_apd_blueform USING btree (hour);


--
-- Name: atd_apd_blueform_latitude_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_apd_blueform_latitude_index ON public.atd_apd_blueform USING btree (latitude);


--
-- Name: atd_apd_blueform_location_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_apd_blueform_location_id_index ON public.atd_apd_blueform USING btree (location_id);


--
-- Name: atd_apd_blueform_longitude_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_apd_blueform_longitude_index ON public.atd_apd_blueform USING btree (longitude);


--
-- Name: atd_apd_blueform_position_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_apd_blueform_position_index ON public.atd_apd_blueform USING gist ("position");


--
-- Name: atd_jurisdictions_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_jurisdictions_geom_idx ON public.atd_jurisdictions USING gist (geometry);


--
-- Name: atd_txdot_locations_council_district_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_txdot_locations_council_district_idx ON public.atd_txdot_locations USING btree (council_district);


--
-- Name: atd_txdot_locations_geometry_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_txdot_locations_geometry_index ON public.atd_txdot_locations USING gist (geometry);


--
-- Name: atd_txdot_locations_group_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX atd_txdot_locations_group_index ON public.atd_txdot_locations USING btree (location_group);


--
-- Name: atd_txdot_locations_unique_id_uindex; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX atd_txdot_locations_unique_id_uindex ON public.atd_txdot_locations USING btree (location_id);


--
-- Name: change_log_crashes_cris_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_crashes_cris_record_id_idx ON public.change_log_crashes_cris USING btree (record_id);


--
-- Name: change_log_crashes_edits_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_crashes_edits_record_id_idx ON public.change_log_crashes_edits USING btree (record_id);


--
-- Name: change_log_crashes_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_crashes_record_id_idx ON public.change_log_crashes USING btree (record_id);


--
-- Name: change_log_people_cris_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_people_cris_record_id_idx ON public.change_log_people_cris USING btree (record_id);


--
-- Name: change_log_people_edits_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_people_edits_record_id_idx ON public.change_log_people_edits USING btree (record_id);


--
-- Name: change_log_people_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_people_record_id_idx ON public.change_log_people USING btree (record_id);


--
-- Name: change_log_units_cris_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_units_cris_record_id_idx ON public.change_log_units_cris USING btree (record_id);


--
-- Name: change_log_units_edits_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_units_edits_record_id_idx ON public.change_log_units_edits USING btree (record_id);


--
-- Name: change_log_units_record_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX change_log_units_record_id_idx ON public.change_log_units USING btree (record_id);


--
-- Name: council_districts_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX council_districts_gix ON public.council_districts USING gist (geometry);


--
-- Name: crashes_address_primary_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_address_primary_idx ON public.crashes USING btree (address_primary);


--
-- Name: crashes_crash_timestamp_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_crash_timestamp_idx ON public.crashes USING btree (crash_timestamp);


--
-- Name: crashes_cris_crash_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_cris_crash_id_idx ON public.crashes USING btree (cris_crash_id);


--
-- Name: crashes_in_austin_full_purpose_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_in_austin_full_purpose_idx ON public.crashes USING btree (in_austin_full_purpose);


--
-- Name: crashes_is_deleted_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_is_deleted_idx ON public.crashes USING btree (is_deleted);


--
-- Name: crashes_location_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_location_id_idx ON public.crashes USING btree (location_id);


--
-- Name: crashes_position_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_position_idx ON public.crashes USING gist ("position");


--
-- Name: crashes_private_dr_fl_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_private_dr_fl_idx ON public.crashes USING btree (private_dr_fl);


--
-- Name: crashes_record_locator_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX crashes_record_locator_idx ON public.crashes USING btree (record_locator);


--
-- Name: engineering_areas_gix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX engineering_areas_gix ON public.engineering_areas USING gist (geometry);


--
-- Name: non_cr3_mainlanes_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX non_cr3_mainlanes_geom_idx ON public.non_cr3_mainlanes USING gist (geometry);


--
-- Name: people_cris_cris_crash_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_cris_cris_crash_id_idx ON public.people_cris USING btree (cris_crash_id);


--
-- Name: people_cris_cris_crash_id_unit_nbr_prsn_nbr_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_cris_cris_crash_id_unit_nbr_prsn_nbr_idx ON public.people_cris USING btree (cris_crash_id, unit_nbr, prsn_nbr);


--
-- Name: people_cris_prsn_injry_sev_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_cris_prsn_injry_sev_id_idx ON public.people_cris USING btree (prsn_injry_sev_id);


--
-- Name: people_cris_unit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_cris_unit_id_idx ON public.people_cris USING btree (unit_id);


--
-- Name: people_prsn_injry_sev_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_prsn_injry_sev_id_idx ON public.people USING btree (prsn_injry_sev_id);


--
-- Name: people_unit_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX people_unit_id_idx ON public.people USING btree (unit_id);


--
-- Name: units_crash_pk_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX units_crash_pk_idx ON public.units USING btree (crash_pk);


--
-- Name: units_cris_cris_crash_id_unit_nbr_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX units_cris_cris_crash_id_unit_nbr_idx ON public.units_cris USING btree (cris_crash_id, unit_nbr);


--
-- Name: unit_injury_metrics_view _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.unit_injury_metrics_view AS
 SELECT units.id,
    units.crash_pk,
    COALESCE(sum(person_injury_metrics_view.unkn_injry), (0)::bigint) AS unkn_injry_count,
    COALESCE(sum(person_injury_metrics_view.nonincap_injry), (0)::bigint) AS nonincap_injry_count,
    COALESCE(sum(person_injury_metrics_view.poss_injry), (0)::bigint) AS poss_injry_count,
    COALESCE(sum(person_injury_metrics_view.non_injry), (0)::bigint) AS non_injry_count,
    COALESCE(sum(person_injury_metrics_view.sus_serious_injry), (0)::bigint) AS sus_serious_injry_count,
    COALESCE(sum(person_injury_metrics_view.fatal_injury), (0)::bigint) AS fatality_count,
    COALESCE(sum(person_injury_metrics_view.vz_fatal_injury), (0)::bigint) AS vz_fatality_count,
    COALESCE(sum(person_injury_metrics_view.law_enf_fatal_injury), (0)::bigint) AS law_enf_fatality_count,
    COALESCE(sum(person_injury_metrics_view.cris_fatal_injury), (0)::bigint) AS cris_fatality_count,
    COALESCE(sum(person_injury_metrics_view.years_of_life_lost), (0)::bigint) AS years_of_life_lost
   FROM (public.units
     LEFT JOIN public.person_injury_metrics_view ON ((units.id = person_injury_metrics_view.unit_id)))
  WHERE (units.is_deleted = false)
  GROUP BY units.id;


--
-- Name: afd__incidents afd_incidents_trigger_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER afd_incidents_trigger_insert AFTER INSERT ON public.afd__incidents FOR EACH ROW EXECUTE FUNCTION public.afd_incidents_trigger();


--
-- Name: afd__incidents afd_incidents_trigger_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER afd_incidents_trigger_update AFTER UPDATE ON public.afd__incidents FOR EACH ROW WHEN ((false OR (old.geometry IS DISTINCT FROM new.geometry) OR (old.ems_incident_numbers IS DISTINCT FROM new.ems_incident_numbers) OR (old.call_datetime IS DISTINCT FROM new.call_datetime))) EXECUTE FUNCTION public.afd_incidents_trigger();


--
-- Name: atd_apd_blueform atd_txdot_blueform_update_position; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER atd_txdot_blueform_update_position BEFORE INSERT OR UPDATE ON public.atd_apd_blueform FOR EACH ROW EXECUTE FUNCTION public.atd_txdot_blueform_update_position();


--
-- Name: crashes_cris crashes_cris_preserve_investigator_narrative_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER crashes_cris_preserve_investigator_narrative_on_update BEFORE UPDATE ON public.crashes_cris FOR EACH ROW WHEN (((new.investigator_narrative IS NULL) AND (old.investigator_narrative IS NOT NULL))) EXECUTE FUNCTION public.crashes_cris_set_old_investigator_narrative();


--
-- Name: crashes crashes_set_spatial_attributes_on_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER crashes_set_spatial_attributes_on_insert BEFORE INSERT ON public.crashes FOR EACH ROW EXECUTE FUNCTION public.crashes_set_spatial_attributes();


--
-- Name: crashes crashes_set_spatial_attributes_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER crashes_set_spatial_attributes_on_update BEFORE UPDATE ON public.crashes FOR EACH ROW WHEN (((new.latitude IS DISTINCT FROM old.latitude) OR (new.longitude IS DISTINCT FROM old.longitude) OR (new.rpt_road_part_id IS DISTINCT FROM old.rpt_road_part_id) OR (new.rpt_hwy_num IS DISTINCT FROM old.rpt_hwy_num))) EXECUTE FUNCTION public.crashes_set_spatial_attributes();


--
-- Name: ems__incidents ems_incidents_trigger_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ems_incidents_trigger_insert AFTER INSERT ON public.ems__incidents FOR EACH ROW EXECUTE FUNCTION public.ems_incidents_trigger();


--
-- Name: ems__incidents ems_incidents_trigger_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER ems_incidents_trigger_update AFTER UPDATE ON public.ems__incidents FOR EACH ROW WHEN ((false OR (old.geometry IS DISTINCT FROM new.geometry) OR (old.apd_incident_numbers IS DISTINCT FROM new.apd_incident_numbers) OR (old.mvc_form_extrication_datetime IS DISTINCT FROM new.mvc_form_extrication_datetime))) EXECUTE FUNCTION public.ems_incidents_trigger();


--
-- Name: crashes insert_change_log_crashes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_crashes AFTER INSERT OR UPDATE ON public.crashes FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: crashes_cris insert_change_log_crashes_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_crashes_cris AFTER INSERT OR UPDATE ON public.crashes_cris FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: crashes_edits insert_change_log_crashes_edits; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_crashes_edits AFTER INSERT OR UPDATE ON public.crashes_edits FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: people insert_change_log_people; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_people AFTER INSERT OR UPDATE ON public.people FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: people_cris insert_change_log_people_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_people_cris AFTER INSERT OR UPDATE ON public.people_cris FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: people_edits insert_change_log_people_edits; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_people_edits AFTER INSERT OR UPDATE ON public.people_edits FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: units insert_change_log_units; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_units AFTER INSERT OR UPDATE ON public.units FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: units_cris insert_change_log_units_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_units_cris AFTER INSERT OR UPDATE ON public.units_cris FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: units_edits insert_change_log_units_edits; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_change_log_units_edits AFTER INSERT OR UPDATE ON public.units_edits FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: crashes_cris insert_new_crashes_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_new_crashes_cris AFTER INSERT ON public.crashes_cris FOR EACH ROW EXECUTE FUNCTION public.crashes_cris_insert_rows();


--
-- Name: people_cris insert_new_people_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_new_people_cris AFTER INSERT ON public.people_cris FOR EACH ROW EXECUTE FUNCTION public.people_cris_insert_rows();


--
-- Name: units_cris insert_new_units_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER insert_new_units_cris AFTER INSERT ON public.units_cris FOR EACH ROW EXECUTE FUNCTION public.units_cris_insert_rows();


--
-- Name: charges_cris set_charges_cris_person_id_and_crash_pk; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_charges_cris_person_id_and_crash_pk BEFORE INSERT ON public.charges_cris FOR EACH ROW EXECUTE FUNCTION public.charges_cris_set_person_id_and_crash_pk();


--
-- Name: people_cris set_person_cris_unit_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_person_cris_unit_id BEFORE INSERT ON public.people_cris FOR EACH ROW EXECUTE FUNCTION public.people_cris_set_unit_id();


--
-- Name: location_notes set_public_location_notes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_public_location_notes_updated_at BEFORE UPDATE ON public.location_notes FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_location_notes_updated_at ON location_notes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER set_public_location_notes_updated_at ON public.location_notes IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: crash_notes set_public_notes_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_public_notes_updated_at BEFORE UPDATE ON public.crash_notes FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();


--
-- Name: TRIGGER set_public_notes_updated_at ON crash_notes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER set_public_notes_updated_at ON public.crash_notes IS 'trigger to set value of column "updated_at" to current timestamp on row update';


--
-- Name: units_cris set_units_cris_crash_id; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_units_cris_crash_id BEFORE INSERT ON public.units_cris FOR EACH ROW EXECUTE FUNCTION public.units_cris_set_unit_id();


--
-- Name: crashes set_updated_at_timestamp_crashes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_crashes BEFORE UPDATE ON public.crashes FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: crashes_cris set_updated_at_timestamp_crashes_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_crashes_cris BEFORE UPDATE ON public.crashes_cris FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: crashes_edits set_updated_at_timestamp_crashes_edits; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_crashes_edits BEFORE UPDATE ON public.crashes_edits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: people set_updated_at_timestamp_people; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_people BEFORE UPDATE ON public.people FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: people_cris set_updated_at_timestamp_people_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_people_cris BEFORE UPDATE ON public.people_cris FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: people_edits set_updated_at_timestamp_people_edits; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_people_edits BEFORE UPDATE ON public.people_edits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: units set_updated_at_timestamp_units; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_units BEFORE UPDATE ON public.units FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: units_cris set_updated_at_timestamp_units_cris; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_units_cris BEFORE UPDATE ON public.units_cris FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: units_edits set_updated_at_timestamp_units_edits; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_timestamp_units_edits BEFORE UPDATE ON public.units_edits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();


--
-- Name: crashes_cris update_crashes_from_crashes_cris_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_crashes_from_crashes_cris_update AFTER UPDATE ON public.crashes_cris FOR EACH ROW EXECUTE FUNCTION public.crashes_cris_update();


--
-- Name: crashes_edits update_crashes_from_crashes_edits_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_crashes_from_crashes_edits_update AFTER UPDATE ON public.crashes_edits FOR EACH ROW EXECUTE FUNCTION public.crashes_edits_update();


--
-- Name: atd_apd_blueform update_noncr3_location_on_insert; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_noncr3_location_on_insert BEFORE INSERT ON public.atd_apd_blueform FOR EACH ROW WHEN (((new.latitude IS NOT NULL) AND (new.longitude IS NOT NULL))) EXECUTE FUNCTION public.update_noncr3_location();


--
-- Name: atd_apd_blueform update_noncr3_location_on_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_noncr3_location_on_update BEFORE UPDATE ON public.atd_apd_blueform FOR EACH ROW WHEN (((old.latitude IS DISTINCT FROM new.latitude) OR (old.longitude IS DISTINCT FROM new.longitude))) EXECUTE FUNCTION public.update_noncr3_location();


--
-- Name: people_cris update_people_from_people_cris_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_people_from_people_cris_update AFTER UPDATE ON public.people_cris FOR EACH ROW EXECUTE FUNCTION public.people_cris_update();


--
-- Name: people_edits update_people_from_people_edits_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_people_from_people_edits_update AFTER UPDATE ON public.people_edits FOR EACH ROW EXECUTE FUNCTION public.people_edits_update();


--
-- Name: units_cris update_units_from_units_cris_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_units_from_units_cris_update AFTER UPDATE ON public.units_cris FOR EACH ROW EXECUTE FUNCTION public.units_cris_update();


--
-- Name: units_edits update_units_from_units_edits_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_units_from_units_edits_update AFTER UPDATE ON public.units_edits FOR EACH ROW EXECUTE FUNCTION public.units_edits_update();


--
-- Name: change_log_crashes_cris change_log_crashes_cris_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes_cris
    ADD CONSTRAINT change_log_crashes_cris_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.crashes_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_crashes_edits change_log_crashes_edits_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes_edits
    ADD CONSTRAINT change_log_crashes_edits_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.crashes_edits(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_crashes change_log_crashes_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_crashes
    ADD CONSTRAINT change_log_crashes_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.crashes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_people_cris change_log_people_cris_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people_cris
    ADD CONSTRAINT change_log_people_cris_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.people_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_people_edits change_log_people_edits_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people_edits
    ADD CONSTRAINT change_log_people_edits_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.people_edits(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_people change_log_people_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_people
    ADD CONSTRAINT change_log_people_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.people(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_units_cris change_log_units_cris_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units_cris
    ADD CONSTRAINT change_log_units_cris_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.units_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_units_edits change_log_units_edits_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units_edits
    ADD CONSTRAINT change_log_units_edits_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.units_edits(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: change_log_units change_log_units_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.change_log_units
    ADD CONSTRAINT change_log_units_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: charges_cris charges_cris_crash_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges_cris
    ADD CONSTRAINT charges_cris_crash_pk_fkey FOREIGN KEY (crash_pk) REFERENCES public.crashes_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: charges_cris charges_cris_cris_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges_cris
    ADD CONSTRAINT charges_cris_cris_crash_id_fkey FOREIGN KEY (cris_crash_id) REFERENCES public.crashes_cris(cris_crash_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: charges_cris charges_cris_person_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.charges_cris
    ADD CONSTRAINT charges_cris_person_id_fkey FOREIGN KEY (person_id) REFERENCES public.people_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: crashes_cris crashes_cris_fhe_collsn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_fhe_collsn_id_fkey FOREIGN KEY (fhe_collsn_id) REFERENCES lookups.collsn(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_intrsct_relat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_intrsct_relat_id_fkey FOREIGN KEY (intrsct_relat_id) REFERENCES lookups.intrsct_relat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_investigat_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_investigat_agency_id_fkey FOREIGN KEY (investigat_agency_id) REFERENCES lookups.agency(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_light_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_light_cond_id_fkey FOREIGN KEY (light_cond_id) REFERENCES lookups.light_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_obj_struck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_obj_struck_id_fkey FOREIGN KEY (obj_struck_id) REFERENCES lookups.obj_struck(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_rpt_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_rpt_city_id_fkey FOREIGN KEY (rpt_city_id) REFERENCES lookups.city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_rpt_cris_cnty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_rpt_cris_cnty_id_fkey FOREIGN KEY (rpt_cris_cnty_id) REFERENCES lookups.cnty(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_rpt_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_rpt_rdwy_sys_id_fkey FOREIGN KEY (rpt_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_rpt_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_rpt_road_part_id_fkey FOREIGN KEY (rpt_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_rpt_sec_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_rpt_sec_rdwy_sys_id_fkey FOREIGN KEY (rpt_sec_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_rpt_sec_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_rpt_sec_road_part_id_fkey FOREIGN KEY (rpt_sec_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_surf_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_surf_cond_id_fkey FOREIGN KEY (surf_cond_id) REFERENCES lookups.surf_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_surf_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_surf_type_id_fkey FOREIGN KEY (surf_type_id) REFERENCES lookups.surf_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_traffic_cntl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_traffic_cntl_id_fkey FOREIGN KEY (traffic_cntl_id) REFERENCES lookups.traffic_cntl(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_cris crashes_cris_wthr_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_cris
    ADD CONSTRAINT crashes_cris_wthr_cond_id_fkey FOREIGN KEY (wthr_cond_id) REFERENCES lookups.wthr_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_fhe_collsn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_fhe_collsn_id_fkey FOREIGN KEY (fhe_collsn_id) REFERENCES lookups.collsn(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_id_fkey FOREIGN KEY (id) REFERENCES public.crashes_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: crashes_edits crashes_edits_intrsct_relat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_intrsct_relat_id_fkey FOREIGN KEY (intrsct_relat_id) REFERENCES lookups.intrsct_relat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_investigat_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_investigat_agency_id_fkey FOREIGN KEY (investigat_agency_id) REFERENCES lookups.agency(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_light_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_light_cond_id_fkey FOREIGN KEY (light_cond_id) REFERENCES lookups.light_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_obj_struck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_obj_struck_id_fkey FOREIGN KEY (obj_struck_id) REFERENCES lookups.obj_struck(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_city_id_fkey FOREIGN KEY (rpt_city_id) REFERENCES lookups.city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_cris_cnty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_cris_cnty_id_fkey FOREIGN KEY (rpt_cris_cnty_id) REFERENCES lookups.cnty(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_rdwy_sys_id_fkey FOREIGN KEY (rpt_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_road_part_id_fkey FOREIGN KEY (rpt_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_sec_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_sec_rdwy_sys_id_fkey FOREIGN KEY (rpt_sec_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_sec_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_sec_road_part_id_fkey FOREIGN KEY (rpt_sec_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_surf_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_surf_cond_id_fkey FOREIGN KEY (surf_cond_id) REFERENCES lookups.surf_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_surf_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_surf_type_id_fkey FOREIGN KEY (surf_type_id) REFERENCES lookups.surf_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_traffic_cntl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_traffic_cntl_id_fkey FOREIGN KEY (traffic_cntl_id) REFERENCES lookups.traffic_cntl(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_wthr_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_wthr_cond_id_fkey FOREIGN KEY (wthr_cond_id) REFERENCES lookups.wthr_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_engineering_area_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_engineering_area_fkey FOREIGN KEY (engineering_area_id) REFERENCES public.engineering_areas(area_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: crashes crashes_fhe_collsn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_fhe_collsn_id_fkey FOREIGN KEY (fhe_collsn_id) REFERENCES lookups.collsn(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_id_fkey FOREIGN KEY (id) REFERENCES public.crashes_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: crashes crashes_intrsct_relat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_intrsct_relat_id_fkey FOREIGN KEY (intrsct_relat_id) REFERENCES lookups.intrsct_relat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_investigat_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_investigat_agency_id_fkey FOREIGN KEY (investigat_agency_id) REFERENCES lookups.agency(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_light_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_light_cond_id_fkey FOREIGN KEY (light_cond_id) REFERENCES lookups.light_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.atd_txdot_locations(location_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: crashes crashes_obj_struck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_obj_struck_id_fkey FOREIGN KEY (obj_struck_id) REFERENCES lookups.obj_struck(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_rpt_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_rpt_city_id_fkey FOREIGN KEY (rpt_city_id) REFERENCES lookups.city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_rpt_cris_cnty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_rpt_cris_cnty_id_fkey FOREIGN KEY (rpt_cris_cnty_id) REFERENCES lookups.cnty(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_rpt_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_rpt_rdwy_sys_id_fkey FOREIGN KEY (rpt_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_rpt_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_rpt_road_part_id_fkey FOREIGN KEY (rpt_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_rpt_sec_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_rpt_sec_rdwy_sys_id_fkey FOREIGN KEY (rpt_sec_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_rpt_sec_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_rpt_sec_road_part_id_fkey FOREIGN KEY (rpt_sec_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_surf_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_surf_cond_id_fkey FOREIGN KEY (surf_cond_id) REFERENCES lookups.surf_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_surf_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_surf_type_id_fkey FOREIGN KEY (surf_type_id) REFERENCES lookups.surf_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_traffic_cntl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_traffic_cntl_id_fkey FOREIGN KEY (traffic_cntl_id) REFERENCES lookups.traffic_cntl(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes crashes_wthr_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crashes
    ADD CONSTRAINT crashes_wthr_cond_id_fkey FOREIGN KEY (wthr_cond_id) REFERENCES lookups.wthr_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: location_notes fk_location_note_location; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.location_notes
    ADD CONSTRAINT fk_location_note_location FOREIGN KEY (location_id) REFERENCES public.atd_txdot_locations(location_id);


--
-- Name: crash_notes notes_crashes_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.crash_notes
    ADD CONSTRAINT notes_crashes_id_fkey FOREIGN KEY (crash_pk) REFERENCES public.crashes(id);


--
-- Name: people_cris people_cris_cris_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_cris_crash_id_fkey FOREIGN KEY (cris_crash_id) REFERENCES public.crashes_cris(cris_crash_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: people_cris people_cris_drvr_drg_cat_1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_drvr_drg_cat_1_id_fkey FOREIGN KEY (drvr_drg_cat_1_id) REFERENCES lookups.substnc_cat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_drvr_lic_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_drvr_lic_type_id_fkey FOREIGN KEY (drvr_lic_type_id) REFERENCES lookups.drvr_lic_type(id);


--
-- Name: people_cris people_cris_prsn_alc_rslt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_alc_rslt_id_fkey FOREIGN KEY (prsn_alc_rslt_id) REFERENCES lookups.substnc_tst_result(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_alc_spec_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_alc_spec_type_id_fkey FOREIGN KEY (prsn_alc_spec_type_id) REFERENCES lookups.specimen_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_drg_rslt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_drg_rslt_id_fkey FOREIGN KEY (prsn_drg_rslt_id) REFERENCES lookups.substnc_tst_result(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_drg_spec_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_drg_spec_type_id_fkey FOREIGN KEY (prsn_drg_spec_type_id) REFERENCES lookups.specimen_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_ethnicity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_ethnicity_id_fkey FOREIGN KEY (prsn_ethnicity_id) REFERENCES lookups.drvr_ethncty(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_gndr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_gndr_id_fkey FOREIGN KEY (prsn_gndr_id) REFERENCES lookups.gndr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_helmet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_helmet_id_fkey FOREIGN KEY (prsn_helmet_id) REFERENCES lookups.helmet(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_injry_sev_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_injry_sev_id_fkey FOREIGN KEY (prsn_injry_sev_id) REFERENCES lookups.injry_sev(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_occpnt_pos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_occpnt_pos_id_fkey FOREIGN KEY (prsn_occpnt_pos_id) REFERENCES lookups.occpnt_pos(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_rest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_rest_id_fkey FOREIGN KEY (prsn_rest_id) REFERENCES lookups.rest(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_prsn_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_prsn_type_id_fkey FOREIGN KEY (prsn_type_id) REFERENCES lookups.prsn_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_cris people_cris_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_cris
    ADD CONSTRAINT people_cris_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: people people_drvr_drg_cat_1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_drvr_drg_cat_1_id_fkey FOREIGN KEY (drvr_drg_cat_1_id) REFERENCES lookups.substnc_cat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_drvr_lic_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_drvr_lic_type_id_fkey FOREIGN KEY (drvr_lic_type_id) REFERENCES lookups.drvr_lic_type(id);


--
-- Name: people_edits people_edits_drvr_drg_cat_1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_drvr_drg_cat_1_id_fkey FOREIGN KEY (drvr_drg_cat_1_id) REFERENCES lookups.substnc_cat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_drvr_lic_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_drvr_lic_type_id_fkey FOREIGN KEY (drvr_lic_type_id) REFERENCES lookups.drvr_lic_type(id);


--
-- Name: people_edits people_edits_ems_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_ems_id_fkey FOREIGN KEY (ems_id) REFERENCES public.ems__incidents(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: people_edits people_edits_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_id_fkey FOREIGN KEY (id) REFERENCES public.people_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: people_edits people_edits_prsn_alc_rslt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_alc_rslt_id_fkey FOREIGN KEY (prsn_alc_rslt_id) REFERENCES lookups.substnc_tst_result(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_alc_spec_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_alc_spec_type_id_fkey FOREIGN KEY (prsn_alc_spec_type_id) REFERENCES lookups.specimen_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_drg_rslt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_drg_rslt_id_fkey FOREIGN KEY (prsn_drg_rslt_id) REFERENCES lookups.substnc_tst_result(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_drg_spec_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_drg_spec_type_id_fkey FOREIGN KEY (prsn_drg_spec_type_id) REFERENCES lookups.specimen_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_ethnicity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_ethnicity_id_fkey FOREIGN KEY (prsn_ethnicity_id) REFERENCES lookups.drvr_ethncty(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_gndr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_gndr_id_fkey FOREIGN KEY (prsn_gndr_id) REFERENCES lookups.gndr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_helmet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_helmet_id_fkey FOREIGN KEY (prsn_helmet_id) REFERENCES lookups.helmet(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_injry_sev_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_injry_sev_id_fkey FOREIGN KEY (prsn_injry_sev_id) REFERENCES lookups.injry_sev(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_occpnt_pos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_occpnt_pos_id_fkey FOREIGN KEY (prsn_occpnt_pos_id) REFERENCES lookups.occpnt_pos(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_rest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_rest_id_fkey FOREIGN KEY (prsn_rest_id) REFERENCES lookups.rest(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_prsn_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_prsn_type_id_fkey FOREIGN KEY (prsn_type_id) REFERENCES lookups.prsn_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people_edits people_edits_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people_edits
    ADD CONSTRAINT people_edits_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: people people_ems_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_ems_id_fkey FOREIGN KEY (ems_id) REFERENCES public.ems__incidents(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: people people_prsn_alc_rslt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_alc_rslt_id_fkey FOREIGN KEY (prsn_alc_rslt_id) REFERENCES lookups.substnc_tst_result(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_alc_spec_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_alc_spec_type_id_fkey FOREIGN KEY (prsn_alc_spec_type_id) REFERENCES lookups.specimen_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_drg_rslt_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_drg_rslt_id_fkey FOREIGN KEY (prsn_drg_rslt_id) REFERENCES lookups.substnc_tst_result(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_drg_spec_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_drg_spec_type_id_fkey FOREIGN KEY (prsn_drg_spec_type_id) REFERENCES lookups.specimen_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_ethnicity_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_ethnicity_id_fkey FOREIGN KEY (prsn_ethnicity_id) REFERENCES lookups.drvr_ethncty(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_gndr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_gndr_id_fkey FOREIGN KEY (prsn_gndr_id) REFERENCES lookups.gndr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_helmet_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_helmet_id_fkey FOREIGN KEY (prsn_helmet_id) REFERENCES lookups.helmet(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_injry_sev_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_injry_sev_id_fkey FOREIGN KEY (prsn_injry_sev_id) REFERENCES lookups.injry_sev(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_occpnt_pos_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_occpnt_pos_id_fkey FOREIGN KEY (prsn_occpnt_pos_id) REFERENCES lookups.occpnt_pos(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_rest_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_rest_id_fkey FOREIGN KEY (prsn_rest_id) REFERENCES lookups.rest(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_prsn_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_prsn_type_id_fkey FOREIGN KEY (prsn_type_id) REFERENCES lookups.prsn_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: people people_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: recommendations recommendations_crashes_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_crashes_pk_fkey FOREIGN KEY (crash_pk) REFERENCES public.crashes(id);


--
-- Name: recommendations_partners recommendations_partners_partner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations_partners
    ADD CONSTRAINT recommendations_partners_partner_id_fkey FOREIGN KEY (partner_id) REFERENCES public.atd__coordination_partners_lkp(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: recommendations_partners recommendations_partners_recommendation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations_partners
    ADD CONSTRAINT recommendations_partners_recommendation_id_fkey FOREIGN KEY (recommendation_id) REFERENCES public.recommendations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: recommendations recommendations_recommendation_status_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recommendations
    ADD CONSTRAINT recommendations_recommendation_status_id_fkey FOREIGN KEY (recommendation_status_id) REFERENCES public.atd__recommendation_status_lkp(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: units units_autonomous_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_autonomous_unit_id_fkey FOREIGN KEY (autonomous_unit_id) REFERENCES lookups.autonomous_unit(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_contrib_factr_1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_contrib_factr_1_id_fkey FOREIGN KEY (contrib_factr_1_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_contrib_factr_2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_contrib_factr_2_id_fkey FOREIGN KEY (contrib_factr_2_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_contrib_factr_3_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_contrib_factr_3_id_fkey FOREIGN KEY (contrib_factr_3_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_contrib_factr_p1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_contrib_factr_p1_id_fkey FOREIGN KEY (contrib_factr_p1_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_contrib_factr_p2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_contrib_factr_p2_id_fkey FOREIGN KEY (contrib_factr_p2_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_crash_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_crash_pk_fkey FOREIGN KEY (crash_pk) REFERENCES public.crashes(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_cris units_cris_autonomous_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_autonomous_unit_id_fkey FOREIGN KEY (autonomous_unit_id) REFERENCES lookups.autonomous_unit(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_contrib_factr_1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_contrib_factr_1_id_fkey FOREIGN KEY (contrib_factr_1_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_contrib_factr_2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_contrib_factr_2_id_fkey FOREIGN KEY (contrib_factr_2_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_contrib_factr_3_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_contrib_factr_3_id_fkey FOREIGN KEY (contrib_factr_3_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_contrib_factr_p1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_contrib_factr_p1_id_fkey FOREIGN KEY (contrib_factr_p1_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_contrib_factr_p2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_contrib_factr_p2_id_fkey FOREIGN KEY (contrib_factr_p2_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_cris_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_cris_crash_id_fkey FOREIGN KEY (cris_crash_id) REFERENCES public.crashes(cris_crash_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_cris units_cris_crash_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_crash_pk_fkey FOREIGN KEY (crash_pk) REFERENCES public.crashes_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_cris units_cris_cris_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_cris_crash_id_fkey FOREIGN KEY (cris_crash_id) REFERENCES public.crashes_cris(cris_crash_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_cris units_cris_e_scooter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_e_scooter_id_fkey FOREIGN KEY (e_scooter_id) REFERENCES lookups.e_scooter(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_first_harm_evt_inv_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_first_harm_evt_inv_id_fkey FOREIGN KEY (first_harm_evt_inv_id) REFERENCES lookups.harm_evnt(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_pbcat_pedalcyclist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_pbcat_pedalcyclist_id_fkey FOREIGN KEY (pbcat_pedalcyclist_id) REFERENCES lookups.pbcat_pedalcyclist(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_pbcat_pedestrian_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_pbcat_pedestrian_id_fkey FOREIGN KEY (pbcat_pedestrian_id) REFERENCES lookups.pbcat_pedestrian(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_pedalcyclist_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_pedalcyclist_action_id_fkey FOREIGN KEY (pedalcyclist_action_id) REFERENCES lookups.pedalcyclist_action(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_pedestrian_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_pedestrian_action_id_fkey FOREIGN KEY (pedestrian_action_id) REFERENCES lookups.pedestrian_action(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_rpt_autonomous_level_engaged_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_rpt_autonomous_level_engaged_id_fkey FOREIGN KEY (rpt_autonomous_level_engaged_id) REFERENCES lookups.autonomous_level_engaged(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_unit_desc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_unit_desc_id_fkey FOREIGN KEY (unit_desc_id) REFERENCES lookups.unit_desc(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_body_styl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_body_styl_id_fkey FOREIGN KEY (veh_body_styl_id) REFERENCES lookups.veh_body_styl(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_damage_description1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_damage_description1_id_fkey FOREIGN KEY (veh_damage_description1_id) REFERENCES lookups.veh_damage_description(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_damage_description2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_damage_description2_id_fkey FOREIGN KEY (veh_damage_description2_id) REFERENCES lookups.veh_damage_description(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_damage_direction_of_force1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_damage_direction_of_force1_id_fkey FOREIGN KEY (veh_damage_direction_of_force1_id) REFERENCES lookups.veh_direction_of_force(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_damage_direction_of_force2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_damage_direction_of_force2_id_fkey FOREIGN KEY (veh_damage_direction_of_force2_id) REFERENCES lookups.veh_direction_of_force(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_damage_severity1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_damage_severity1_id_fkey FOREIGN KEY (veh_damage_severity1_id) REFERENCES lookups.veh_damage_severity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_damage_severity2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_damage_severity2_id_fkey FOREIGN KEY (veh_damage_severity2_id) REFERENCES lookups.veh_damage_severity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_make_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_make_id_fkey FOREIGN KEY (veh_make_id) REFERENCES lookups.veh_make(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_mod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_mod_id_fkey FOREIGN KEY (veh_mod_id) REFERENCES lookups.veh_mod(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_cris units_cris_veh_trvl_dir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_cris
    ADD CONSTRAINT units_cris_veh_trvl_dir_id_fkey FOREIGN KEY (veh_trvl_dir_id) REFERENCES lookups.trvl_dir(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_e_scooter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_e_scooter_id_fkey FOREIGN KEY (e_scooter_id) REFERENCES lookups.e_scooter(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_autonomous_unit_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_autonomous_unit_id_fkey FOREIGN KEY (autonomous_unit_id) REFERENCES lookups.autonomous_unit(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_contrib_factr_1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_contrib_factr_1_id_fkey FOREIGN KEY (contrib_factr_1_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_contrib_factr_2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_contrib_factr_2_id_fkey FOREIGN KEY (contrib_factr_2_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_contrib_factr_3_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_contrib_factr_3_id_fkey FOREIGN KEY (contrib_factr_3_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_contrib_factr_p1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_contrib_factr_p1_id_fkey FOREIGN KEY (contrib_factr_p1_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_contrib_factr_p2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_contrib_factr_p2_id_fkey FOREIGN KEY (contrib_factr_p2_id) REFERENCES lookups.contrib_factr(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_crash_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_crash_pk_fkey FOREIGN KEY (crash_pk) REFERENCES public.crashes_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_edits units_edits_cris_crash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_cris_crash_id_fkey FOREIGN KEY (cris_crash_id) REFERENCES public.crashes_cris(cris_crash_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_edits units_edits_e_scooter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_e_scooter_id_fkey FOREIGN KEY (e_scooter_id) REFERENCES lookups.e_scooter(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_first_harm_evt_inv_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_first_harm_evt_inv_id_fkey FOREIGN KEY (first_harm_evt_inv_id) REFERENCES lookups.harm_evnt(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_id_fkey FOREIGN KEY (id) REFERENCES public.units_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: units_edits units_edits_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES lookups.movt(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_pbcat_pedalcyclist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_pbcat_pedalcyclist_id_fkey FOREIGN KEY (pbcat_pedalcyclist_id) REFERENCES lookups.pbcat_pedalcyclist(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_pbcat_pedestrian_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_pbcat_pedestrian_id_fkey FOREIGN KEY (pbcat_pedestrian_id) REFERENCES lookups.pbcat_pedestrian(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_pedalcyclist_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_pedalcyclist_action_id_fkey FOREIGN KEY (pedalcyclist_action_id) REFERENCES lookups.pedalcyclist_action(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_pedestrian_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_pedestrian_action_id_fkey FOREIGN KEY (pedestrian_action_id) REFERENCES lookups.pedestrian_action(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_rpt_autonomous_level_engaged_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_rpt_autonomous_level_engaged_id_fkey FOREIGN KEY (rpt_autonomous_level_engaged_id) REFERENCES lookups.autonomous_level_engaged(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_unit_desc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_unit_desc_id_fkey FOREIGN KEY (unit_desc_id) REFERENCES lookups.unit_desc(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_body_styl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_body_styl_id_fkey FOREIGN KEY (veh_body_styl_id) REFERENCES lookups.veh_body_styl(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_damage_description1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_damage_description1_id_fkey FOREIGN KEY (veh_damage_description1_id) REFERENCES lookups.veh_damage_description(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_damage_description2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_damage_description2_id_fkey FOREIGN KEY (veh_damage_description2_id) REFERENCES lookups.veh_damage_description(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_damage_direction_of_force1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_damage_direction_of_force1_id_fkey FOREIGN KEY (veh_damage_direction_of_force1_id) REFERENCES lookups.veh_direction_of_force(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_damage_direction_of_force2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_damage_direction_of_force2_id_fkey FOREIGN KEY (veh_damage_direction_of_force2_id) REFERENCES lookups.veh_direction_of_force(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_damage_severity1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_damage_severity1_id_fkey FOREIGN KEY (veh_damage_severity1_id) REFERENCES lookups.veh_damage_severity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_damage_severity2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_damage_severity2_id_fkey FOREIGN KEY (veh_damage_severity2_id) REFERENCES lookups.veh_damage_severity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_make_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_make_id_fkey FOREIGN KEY (veh_make_id) REFERENCES lookups.veh_make(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_mod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_mod_id_fkey FOREIGN KEY (veh_mod_id) REFERENCES lookups.veh_mod(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units_edits units_edits_veh_trvl_dir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units_edits
    ADD CONSTRAINT units_edits_veh_trvl_dir_id_fkey FOREIGN KEY (veh_trvl_dir_id) REFERENCES lookups.trvl_dir(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_first_harm_evt_inv_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_first_harm_evt_inv_id_fkey FOREIGN KEY (first_harm_evt_inv_id) REFERENCES lookups.harm_evnt(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_movement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_movement_id_fkey FOREIGN KEY (movement_id) REFERENCES lookups.movt(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_pbcat_pedalcyclist_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pbcat_pedalcyclist_id_fkey FOREIGN KEY (pbcat_pedalcyclist_id) REFERENCES lookups.pbcat_pedalcyclist(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_pbcat_pedestrian_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pbcat_pedestrian_id_fkey FOREIGN KEY (pbcat_pedestrian_id) REFERENCES lookups.pbcat_pedestrian(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_pedalcyclist_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pedalcyclist_action_id_fkey FOREIGN KEY (pedalcyclist_action_id) REFERENCES lookups.pedalcyclist_action(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_pedestrian_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pedestrian_action_id_fkey FOREIGN KEY (pedestrian_action_id) REFERENCES lookups.pedestrian_action(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_rpt_autonomous_level_engaged_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_rpt_autonomous_level_engaged_id_fkey FOREIGN KEY (rpt_autonomous_level_engaged_id) REFERENCES lookups.autonomous_level_engaged(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_unit_desc_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_unit_desc_id_fkey FOREIGN KEY (unit_desc_id) REFERENCES lookups.unit_desc(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_body_styl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_body_styl_id_fkey FOREIGN KEY (veh_body_styl_id) REFERENCES lookups.veh_body_styl(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_damage_description1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_damage_description1_id_fkey FOREIGN KEY (veh_damage_description1_id) REFERENCES lookups.veh_damage_description(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_damage_description2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_damage_description2_id_fkey FOREIGN KEY (veh_damage_description2_id) REFERENCES lookups.veh_damage_description(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_damage_direction_of_force1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_damage_direction_of_force1_id_fkey FOREIGN KEY (veh_damage_direction_of_force1_id) REFERENCES lookups.veh_direction_of_force(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_damage_direction_of_force2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_damage_direction_of_force2_id_fkey FOREIGN KEY (veh_damage_direction_of_force2_id) REFERENCES lookups.veh_direction_of_force(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_damage_severity1_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_damage_severity1_id_fkey FOREIGN KEY (veh_damage_severity1_id) REFERENCES lookups.veh_damage_severity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_damage_severity2_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_damage_severity2_id_fkey FOREIGN KEY (veh_damage_severity2_id) REFERENCES lookups.veh_damage_severity(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_make_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_make_id_fkey FOREIGN KEY (veh_make_id) REFERENCES lookups.veh_make(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_mod_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_mod_id_fkey FOREIGN KEY (veh_mod_id) REFERENCES lookups.veh_mod(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units units_veh_trvl_dir_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_veh_trvl_dir_id_fkey FOREIGN KEY (veh_trvl_dir_id) REFERENCES lookups.trvl_dir(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: units vz_mode_category_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.units
    ADD CONSTRAINT vz_mode_category_fk FOREIGN KEY (vz_mode_category_id) REFERENCES lookups.mode_category(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

