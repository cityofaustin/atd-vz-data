-- Backfill crash notes with the crash_pk
UPDATE
  crash_notes
SET
  crash_pk=crashes.id
FROM
  crashes
WHERE
  crash_notes.atd_txdot_crashes_crash_id=crashes.cris_crash_id;

-- Backfill crash recommendations with the crash_pk
UPDATE
  recommendations
SET
  crash_pk=crashes.id
FROM
  crashes
WHERE
  recommendations.atd_txdot_crashes_crash_id=crashes.cris_crash_id;

-- This is a crufty crash that CRIS has since deleted, it is a dupe of cris crash id 19854368
DELETE FROM recommendations WHERE atd_txdot_crashes_crash_id = 19724784;

DELETE FROM crash_notes WHERE atd_txdot_crashes_crash_id = 19724784;

-- Each record must always have an associated crash_pk
ALTER TABLE recommendations ALTER COLUMN crash_pk SET NOT NULL;

ALTER TABLE crash_notes ALTER COLUMN crash_pk SET NOT NULL;

-- Drop old columns
ALTER TABLE recommendations DROP COLUMN atd_txdot_crashes_crash_id;

ALTER TABLE crash_notes DROP COLUMN atd_txdot_crashes_crash_id;
