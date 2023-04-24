drop trigger if exists trg_vz_create_atd_txdot_crashes ON cris.atd_txdot_crashes;
drop function if exists maintain_vz_schema_crash_records;

drop trigger if exists trg_vz_create_atd_txdot_units ON cris.atd_txdot_units;
drop function if exists maintain_vz_schema_unit_records;

drop trigger if exists trg_vz_create_atd_txdot_person on cris.atd_txdot_person;
drop function if exists maintain_vz_schema_person_records;

drop trigger if exists trg_vz_create_atd_txdot_primaryperson on cris.atd_txdot_primaryperson;
drop function if exists maintain_vz_schema_primaryperson_records;





CREATE OR REPLACE FUNCTION maintain_vz_schema_crash_records()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vz.atd_txdot_crashes (crash_id) VALUES (NEW.crash_id);
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM vz.atd_txdot_crashes WHERE crash_id = OLD.crash_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_vz_create_atd_txdot_crashes
AFTER INSERT OR DELETE
ON cris.atd_txdot_crashes
FOR EACH ROW
EXECUTE FUNCTION maintain_vz_schema_crash_records();






CREATE OR REPLACE FUNCTION maintain_vz_schema_unit_records()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vz.atd_txdot_units (crash_id, unit_nbr) VALUES (NEW.crash_id, NEW.unit_nbr);
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM vz.atd_txdot_units WHERE crash_id = OLD.crash_id and unit_nbr = OLD.unit_nbr;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_vz_create_atd_txdot_units
AFTER INSERT OR DELETE
ON cris.atd_txdot_units
FOR EACH ROW
EXECUTE FUNCTION maintain_vz_schema_unit_records();








CREATE OR REPLACE FUNCTION maintain_vz_schema_person_records()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vz.atd_txdot_person (crash_id, unit_nbr, prsn_nbr) VALUES (NEW.crash_id, NEW.unit_nbr, NEW.prsn_nbr);
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM vz.atd_txdot_person WHERE crash_id = OLD.crash_id and unit_nbr = OLD.unit_nbr and prsn_nbr = OLD.prsn_nbr;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_vz_create_atd_txdot_person
AFTER INSERT OR DELETE
ON cris.atd_txdot_person
FOR EACH ROW
EXECUTE FUNCTION maintain_vz_schema_person_records();







CREATE OR REPLACE FUNCTION maintain_vz_schema_primaryperson_records()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO vz.atd_txdot_primaryperson (crash_id, unit_nbr, prsn_nbr) VALUES (NEW.crash_id, NEW.unit_nbr, NEW.prsn_nbr);
  ELSIF TG_OP = 'DELETE' THEN
    DELETE FROM vz.atd_txdot_primaryperson WHERE crash_id = OLD.crash_id and unit_nbr = OLD.unit_nbr and prsn_nbr = OLD.prsn_nbr;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_vz_create_atd_txdot_primaryperson
AFTER INSERT OR DELETE
ON cris.atd_txdot_primaryperson
FOR EACH ROW
EXECUTE FUNCTION maintain_vz_schema_primaryperson_records();