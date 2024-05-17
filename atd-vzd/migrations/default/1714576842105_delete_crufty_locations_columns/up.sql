-- This is an old crufty view that needs to be dropped bc it has dependencies with some columns we are dropping
DROP VIEW atd_txdot_locations_with_centroids;

-- Removing unused crufty columns
ALTER TABLE atd_txdot_locations
DROP COLUMN IF EXISTS asmp_street_level,
DROP COLUMN IF EXISTS address,
DROP COLUMN IF EXISTS is_retired,
DROP COLUMN IF EXISTS bicycle_score,
DROP COLUMN IF EXISTS broken_out_intersections_union,
DROP COLUMN IF EXISTS community_context_score,
DROP COLUMN IF EXISTS community_dest_score,
DROP COLUMN IF EXISTS cr3_report_count,
DROP COLUMN IF EXISTS crash_history_score,
DROP COLUMN IF EXISTS death_count,
DROP COLUMN IF EXISTS development_engineer_area_id,
DROP COLUMN IF EXISTS intersection,
DROP COLUMN IF EXISTS intersection_union,
DROP COLUMN IF EXISTS is_intersecting_district,
DROP COLUMN IF EXISTS is_studylocation,
DROP COLUMN IF EXISTS is_svrd,
DROP COLUMN IF EXISTS minority_score,
DROP COLUMN IF EXISTS non_cr3_report_count,
DROP COLUMN IF EXISTS non_incapacitating_injury_count,
DROP COLUMN IF EXISTS non_injury_count,
DROP COLUMN IF EXISTS overlapping_geometry,
DROP COLUMN IF EXISTS polygon_hex_id,
DROP COLUMN IF EXISTS polygon_id,
DROP COLUMN IF EXISTS possible_injury_count,
DROP COLUMN IF EXISTS poverty_score,
DROP COLUMN IF EXISTS priority_level,
DROP COLUMN IF EXISTS road,
DROP COLUMN IF EXISTS road_name,
DROP COLUMN IF EXISTS sidewalk_score,
DROP COLUMN IF EXISTS signal_engineer_area_id,
DROP COLUMN IF EXISTS spine,
DROP COLUMN IF EXISTS suspected_serious_injury_count,
DROP COLUMN IF EXISTS total_cc_and_history_score,
DROP COLUMN IF EXISTS total_comprehensive_cost,
DROP COLUMN IF EXISTS total_crash_count,
DROP COLUMN IF EXISTS total_speed_mgmt_points,
DROP COLUMN IF EXISTS transit_score,
DROP COLUMN IF EXISTS level_1,
DROP COLUMN IF EXISTS level_2,
DROP COLUMN IF EXISTS level_3,
DROP COLUMN IF EXISTS level_4,
DROP COLUMN IF EXISTS level_5,
DROP COLUMN IF EXISTS metadata,
DROP COLUMN IF EXISTS unique_id,
DROP COLUMN IF EXISTS shape,
DROP COLUMN IF EXISTS unknown_injury_count;
