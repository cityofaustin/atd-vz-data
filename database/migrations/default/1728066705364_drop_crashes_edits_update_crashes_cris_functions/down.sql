--
-- Name: change_log_crashes_edits; Type: TABLE; Schema: public; Owner: visionzero
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
-- Name: change_log_crashes_edits_id_seq; Type: SEQUENCE; Schema: public; Owner: visionzero
--

CREATE SEQUENCE public.change_log_crashes_edits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: change_log_crashes_edits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: visionzero
--

ALTER SEQUENCE public.change_log_crashes_edits_id_seq OWNED BY public.change_log_crashes_edits.id;


--
-- Name: crashes_edits; Type: TABLE; Schema: public; Owner: visionzero
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
-- Name: COLUMN crashes_edits.investigator_narrative_ocr_processed_at; Type: COMMENT; Schema: public; Owner: visionzero
--

COMMENT ON COLUMN public.crashes_edits.investigator_narrative_ocr_processed_at IS 'The most recent
timestamp at which the OCR process attempted to extract the investigator narrative. If null, 
indicates that the OCR narrative extract has never been attempted. This value should be set
via ETL process.';


--
-- Name: change_log_crashes_edits id; Type: DEFAULT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.change_log_crashes_edits ALTER COLUMN id SET DEFAULT nextval('public.change_log_crashes_edits_id_seq'::regclass);


--
-- Name: change_log_crashes_edits change_log_crashes_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.change_log_crashes_edits
    ADD CONSTRAINT change_log_crashes_edits_pkey PRIMARY KEY (id);


--
-- Name: crashes_edits crashes_edits_cris_crash_id_key; Type: CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_cris_crash_id_key UNIQUE (cris_crash_id);


--
-- Name: crashes_edits crashes_edits_pkey; Type: CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_pkey PRIMARY KEY (id);


--
-- Name: change_log_crashes_edits_record_id_idx; Type: INDEX; Schema: public; Owner: visionzero
--

CREATE INDEX change_log_crashes_edits_record_id_idx ON public.change_log_crashes_edits USING btree (record_id);


--
-- Name: crashes_edits insert_change_log_crashes_edits; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER insert_change_log_crashes_edits AFTER INSERT OR UPDATE ON public.crashes_edits FOR EACH ROW EXECUTE FUNCTION public.insert_change_log();


--
-- Name: crashes_edits set_updated_at_timestamp_crashes_edits; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER set_updated_at_timestamp_crashes_edits BEFORE UPDATE ON public.crashes_edits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at_timestamp();

-- Have to recreate this function
drop function if exists public.crashes_cris_insert_rows cascade;

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

-- Have to recreate this trigger
create or replace trigger insert_new_crashes_cris
after insert on public.crashes_cris
for each row
execute procedure public.crashes_cris_insert_rows();

-- Have to recreate this function
drop function if exists public.crashes_cris_update cascade;

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


-- Adding this trigger back
create trigger update_crashes_from_crashes_cris_update
after update on public.crashes_cris for each row
execute procedure public.crashes_cris_update();

--
-- Name: crashes_edits update_crashes_from_crashes_edits_update; Type: TRIGGER; Schema: public; Owner: visionzero
--

CREATE TRIGGER update_crashes_from_crashes_edits_update AFTER UPDATE ON public.crashes_edits FOR EACH ROW EXECUTE FUNCTION public.crashes_edits_update();


--
-- Name: change_log_crashes_edits change_log_crashes_edits_record_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.change_log_crashes_edits
    ADD CONSTRAINT change_log_crashes_edits_record_id_fkey FOREIGN KEY (record_id) REFERENCES public.crashes_edits(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: crashes_edits crashes_edits_fhe_collsn_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_fhe_collsn_id_fkey FOREIGN KEY (fhe_collsn_id) REFERENCES lookups.collsn(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_id_fkey FOREIGN KEY (id) REFERENCES public.crashes_cris(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: crashes_edits crashes_edits_intrsct_relat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_intrsct_relat_id_fkey FOREIGN KEY (intrsct_relat_id) REFERENCES lookups.intrsct_relat(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_investigat_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_investigat_agency_id_fkey FOREIGN KEY (investigat_agency_id) REFERENCES lookups.agency(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_light_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_light_cond_id_fkey FOREIGN KEY (light_cond_id) REFERENCES lookups.light_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_obj_struck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_obj_struck_id_fkey FOREIGN KEY (obj_struck_id) REFERENCES lookups.obj_struck(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_city_id_fkey FOREIGN KEY (rpt_city_id) REFERENCES lookups.city(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_cris_cnty_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_cris_cnty_id_fkey FOREIGN KEY (rpt_cris_cnty_id) REFERENCES lookups.cnty(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_rdwy_sys_id_fkey FOREIGN KEY (rpt_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_road_part_id_fkey FOREIGN KEY (rpt_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_sec_rdwy_sys_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_sec_rdwy_sys_id_fkey FOREIGN KEY (rpt_sec_rdwy_sys_id) REFERENCES lookups.rwy_sys(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_rpt_sec_road_part_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_rpt_sec_road_part_id_fkey FOREIGN KEY (rpt_sec_road_part_id) REFERENCES lookups.road_part(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_surf_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_surf_cond_id_fkey FOREIGN KEY (surf_cond_id) REFERENCES lookups.surf_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_surf_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_surf_type_id_fkey FOREIGN KEY (surf_type_id) REFERENCES lookups.surf_type(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_traffic_cntl_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_traffic_cntl_id_fkey FOREIGN KEY (traffic_cntl_id) REFERENCES lookups.traffic_cntl(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: crashes_edits crashes_edits_wthr_cond_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: visionzero
--

ALTER TABLE ONLY public.crashes_edits
    ADD CONSTRAINT crashes_edits_wthr_cond_id_fkey FOREIGN KEY (wthr_cond_id) REFERENCES lookups.wthr_cond(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

