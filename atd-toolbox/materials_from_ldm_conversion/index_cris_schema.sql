CREATE INDEX atd_txdot_crashes_apd_confirmed_fatality_index ON cris.atd_txdot_crashes USING btree (apd_confirmed_fatality);
CREATE INDEX atd_txdot_crashes_austin_full_purpose_index ON cris.atd_txdot_crashes USING btree (austin_full_purpose);
CREATE INDEX atd_txdot_crashes_case_id_index ON cris.atd_txdot_crashes USING btree (case_id);
CREATE INDEX atd_txdot_crashes_city_id_index ON cris.atd_txdot_crashes USING btree (city_id);
CREATE INDEX atd_txdot_crashes_cr3_file_metadata_index ON cris.atd_txdot_crashes USING gin (cr3_file_metadata);
CREATE INDEX atd_txdot_crashes_cr3_stored_flag_index ON cris.atd_txdot_crashes USING btree (cr3_stored_flag);
CREATE INDEX atd_txdot_crashes_crash_date_index ON cris.atd_txdot_crashes USING btree (crash_date);
CREATE INDEX atd_txdot_crashes_crash_fatal_fl_index ON cris.atd_txdot_crashes USING btree (crash_fatal_fl);
CREATE INDEX atd_txdot_crashes_death_cnt_index ON cris.atd_txdot_crashes USING btree (death_cnt);
CREATE INDEX atd_txdot_crashes_geocode_provider_index ON cris.atd_txdot_crashes USING btree (geocode_provider);
CREATE INDEX atd_txdot_crashes_geocode_status_index ON cris.atd_txdot_crashes USING btree (geocode_status);
CREATE INDEX atd_txdot_crashes_geocoded_index ON cris.atd_txdot_crashes USING btree (geocoded);
CREATE INDEX atd_txdot_crashes_investigat_agency_id_index ON cris.atd_txdot_crashes USING btree (investigat_agency_id);
CREATE INDEX atd_txdot_crashes_is_retired_index ON cris.atd_txdot_crashes USING btree (is_retired);
CREATE INDEX atd_txdot_crashes_original_city_id_index ON cris.atd_txdot_crashes USING btree (original_city_id);
CREATE INDEX atd_txdot_crashes_position_index ON cris.atd_txdot_crashes USING gist ("position");
CREATE INDEX atd_txdot_crashes_qa_status_index ON cris.atd_txdot_crashes USING btree (qa_status);
CREATE INDEX atd_txdot_crashes_sus_serious_injry_cnt_index ON cris.atd_txdot_crashes USING btree (sus_serious_injry_cnt);
CREATE INDEX atd_txdot_crashes_temp_record_index ON cris.atd_txdot_crashes USING btree (temp_record);


CREATE INDEX atd_txdot_person_death_cnt_index ON cris.atd_txdot_person USING btree (death_cnt);
CREATE INDEX atd_txdot_person_is_retired_index ON cris.atd_txdot_person USING btree (is_retired);
CREATE INDEX atd_txdot_person_person_id_index ON cris.atd_txdot_person USING btree (person_id);
CREATE INDEX atd_txdot_person_prsn_age_index ON cris.atd_txdot_person USING btree (prsn_age);
CREATE INDEX atd_txdot_person_prsn_death_date_index ON cris.atd_txdot_person USING btree (prsn_death_date);
CREATE INDEX atd_txdot_person_prsn_death_time_index ON cris.atd_txdot_person USING btree (prsn_death_time);
CREATE INDEX atd_txdot_person_prsn_ethnicity_id_index ON cris.atd_txdot_person USING btree (prsn_ethnicity_id);
CREATE INDEX atd_txdot_person_prsn_gndr_id_index ON cris.atd_txdot_person USING btree (prsn_gndr_id);
CREATE INDEX atd_txdot_person_prsn_injry_sev_id_index ON cris.atd_txdot_person USING btree (prsn_injry_sev_id);
CREATE INDEX atd_txdot_person_sus_serious_injry_cnt_index ON cris.atd_txdot_person USING btree (sus_serious_injry_cnt);
CREATE INDEX idx_atd_txdot_person_crash_id ON cris.atd_txdot_person USING btree (crash_id);


CREATE INDEX atd_txdot_primaryperson_death_cnt_index ON cris.atd_txdot_primaryperson USING btree (death_cnt);
CREATE INDEX atd_txdot_primaryperson_is_retired_index ON cris.atd_txdot_primaryperson USING btree (is_retired);
CREATE INDEX atd_txdot_primaryperson_primaryperson_id_index ON cris.atd_txdot_primaryperson USING btree (primaryperson_id);
CREATE INDEX atd_txdot_primaryperson_prsn_age_index ON cris.atd_txdot_primaryperson USING btree (prsn_age);
CREATE INDEX atd_txdot_primaryperson_prsn_death_date_index ON cris.atd_txdot_primaryperson USING btree (prsn_death_date);
CREATE INDEX atd_txdot_primaryperson_prsn_death_time_index ON cris.atd_txdot_primaryperson USING btree (prsn_death_time);
CREATE INDEX atd_txdot_primaryperson_prsn_ethnicity_id_index ON cris.atd_txdot_primaryperson USING btree (prsn_ethnicity_id);
CREATE INDEX atd_txdot_primaryperson_prsn_gndr_id_index ON cris.atd_txdot_primaryperson USING btree (prsn_gndr_id);
CREATE INDEX atd_txdot_primaryperson_prsn_injry_sev_id_index ON cris.atd_txdot_primaryperson USING btree (prsn_injry_sev_id);
CREATE INDEX atd_txdot_primaryperson_sus_serious_injry_cnt_index ON cris.atd_txdot_primaryperson USING btree (sus_serious_injry_cnt);
CREATE INDEX idx_atd_txdot_primaryperson_crash_id ON cris.atd_txdot_primaryperson USING btree (crash_id);


CREATE INDEX atd_txdot_units_death_cnt_index ON cris.atd_txdot_units USING btree (death_cnt);
CREATE INDEX atd_txdot_units_movement_id_index ON cris.atd_txdot_units USING btree (movement_id);
CREATE INDEX atd_txdot_units_sus_serious_injry_cnt_index ON cris.atd_txdot_units USING btree (sus_serious_injry_cnt);
CREATE INDEX atd_txdot_units_unit_id_index ON cris.atd_txdot_units USING btree (unit_id);
CREATE INDEX idx_atd_txdot_units_crash_id ON cris.atd_txdot_units USING btree (crash_id);
