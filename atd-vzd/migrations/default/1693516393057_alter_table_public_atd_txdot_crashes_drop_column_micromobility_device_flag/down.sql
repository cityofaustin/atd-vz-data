alter table "public"."atd_txdot_crashes" add column "micromobility_device_flag" character varying(1) DEFAULT 'N'::character varying NOT NULL;
