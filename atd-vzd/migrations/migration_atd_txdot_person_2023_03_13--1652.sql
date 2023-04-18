-- trigger when injury severity is changed
CREATE OR REPLACE TRIGGER atd_txdot_person_update_injry
    AFTER UPDATE ON atd_txdot_person
    FOR EACH ROW
    WHEN (OLD.prsn_injry_sev_id IS DISTINCT FROM NEW.prsn_injry_sev_id)
    EXECUTE FUNCTION update_fatality_soft_delete();
