CREATE INDEX crashes_location_idx ON atd_txdot_crashes (location_id);
CREATE INDEX crashes_crash_date_location_idx ON atd_txdot_crashes (crash_date, location_id);
