CREATE OR REPLACE FUNCTION maintain_vz_schema_crash_records()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' OR TG_OP = 'DELETE' THEN
    INSERT INTO vz.atd_txdot_crashes (crash_id) VALUES (NEW.crash_id);
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
  IF TG_OP = 'INSERT' OR TG_OP = 'DELETE' THEN
    INSERT INTO vz.atd_txdot_units (crash_id, unit_nbr) VALUES (NEW.crash_id, NEW.unit_nbr);
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
  IF TG_OP = 'INSERT' OR TG_OP = 'DELETE' THEN
    INSERT INTO vz.atd_txdot_person (crash_id, unit_nbr, prsn_nbr) VALUES (NEW.crash_id, NEW.unit_nbr, NEW.prsn_nbr);
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
  IF TG_OP = 'INSERT' OR TG_OP = 'DELETE' THEN
    INSERT INTO vz.atd_txdot_primaryperson (crash_id, unit_nbr, prsn_nbr) VALUES (NEW.crash_id, NEW.unit_nbr, NEW.prsn_nbr);
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_vz_create_atd_txdot_primaryperson
AFTER INSERT OR DELETE
ON cris.atd_txdot_primaryperson
FOR EACH ROW
EXECUTE FUNCTION maintain_vz_schema_person_records();