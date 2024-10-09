-- deleting the crash edits layer
drop table if exists public.change_log_crashes_edits cascade;
drop table if exists public.crashes_edits cascade;

-- recreating cris crash insert function and removing part about inserting into crash edits row

drop function if exists public.crashes_cris_insert_rows cascade;

create or replace function public.crashes_cris_insert_rows()
returns trigger
language plpgsql
as
$$
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

    RETURN NULL;
END;
$$;

create or replace trigger insert_new_crashes_cris
after insert on public.crashes_cris
for each row
execute procedure public.crashes_cris_insert_rows();

-- recreating the crashes_cris_update function to use just the crashes unified layer
-- to check if VZ has edited a value and remove the crashes_edits part
drop function if exists public.crashes_cris_update cascade;

--
-- handle a cris crashes update by updating the
-- unified crashes record from cris + edit values
--
create or replace function public.crashes_cris_update()
returns trigger
language plpgsql
as $$
declare
    new_cris_jb jsonb := to_jsonb (new);
    old_cris_jb jsonb := to_jsonb (old);
    unified_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.crashes set ';
begin
    -- get corresponding the VZ record as jsonb
    SELECT to_jsonb(crashes) INTO unified_record_jb from public.crashes where public.crashes.id = new.id;

    -- for every key in the cris json object
    for column_name in select jsonb_object_keys(new_cris_jb) loop
        -- ignore audit fields
        continue when column_name in ('created_at', 'updated_at', 'created_by', 'updated_by');
        -- if the new cris value doesn't match the old cris value
        if(new_cris_jb -> column_name <> old_cris_jb -> column_name) then
            -- see if the unified record has the same value as the old cris value
            if (unified_record_jb -> column_name = old_cris_jb -> column_name) then
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
$$;

create trigger update_crashes_from_crashes_cris_update
after update on public.crashes_cris for each row
execute procedure public.crashes_cris_update();
