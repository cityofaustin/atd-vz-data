DROP TRIGGER ems_incidents_trigger_insert ON ems__incidents;

DROP TRIGGER ems_incidents_trigger_update ON ems__incidents;

DROP FUNCTION public.ems_incidents_trigger();

CREATE FUNCTION public.ems_incidents_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  update ems__incidents set
    austin_full_purpose = (
      select ST_Contains(jurisdiction.geometry, incidents.geometry)
      from ems__incidents incidents
      left join atd_jurisdictions jurisdiction on (jurisdiction.jurisdiction_label = 'AUSTIN FULL PURPOSE')
      where incidents.id = new.id),
    location_id = (
      select locations.location_id
      from ems__incidents incidents
      join atd_txdot_locations locations on (locations.location_group = 1 and incidents.geometry && locations.shape and ST_Contains(locations.shape, incidents.geometry))
      where incidents.id = new.id),
    latitude = ST_Y(ems__incidents.geometry),
    longitude = ST_X(ems__incidents.geometry),
    apd_incident_number_1 = ems__incidents.apd_incident_numbers[1],
    apd_incident_number_2 = ems__incidents.apd_incident_numbers[2],
    mvc_form_date = date(ems__incidents.mvc_form_extrication_datetime),
    mvc_form_time = ems__incidents.mvc_form_extrication_datetime::time
    where ems__incidents.id = new.id;
RETURN NEW;
END;
$$;

create trigger ems_incidents_trigger_insert after
insert
    on
    public.ems__incidents for each row execute function ems_incidents_trigger();

create trigger ems_incidents_trigger_update after
update
    on
    public.ems__incidents for each row
    when ((false
        or (old.geometry is distinct
    from
        new.geometry)
        or (old.apd_incident_numbers is distinct
    from
        new.apd_incident_numbers)
        or (old.mvc_form_extrication_datetime is distinct
    from
        new.mvc_form_extrication_datetime))) execute function ems_incidents_trigger();
