-- Create index for latitude
create index atd_apd_blueform_latitude_index
	on atd_apd_blueform (latitude);

-- Index for longitude
create index atd_apd_blueform_longitude_index
	on atd_apd_blueform (longitude);

-- Index for location_id
create index atd_apd_blueform_location_id_index
	on atd_apd_blueform (location_id);
