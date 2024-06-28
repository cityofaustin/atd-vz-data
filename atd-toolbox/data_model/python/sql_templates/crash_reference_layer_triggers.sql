--
-- add missing geometry index to jurisdictions
--
drop index if exists atd_jurisdictions_geom_idx;
create index atd_jurisdictions_geom_idx on atd_jurisdictions
using gist (geometry);

--
-- Handle various spatial attribute associations when 
-- unified crash record is inserted or updated
--
create or replace function public.crashes_set_spatial_attributes()
returns trigger
language plpgsql
as $$
begin
    if (new.latitude is not null and new.longitude is not null) then
        -- save lat/lon into geometry col
        new.position = st_setsrid(st_makepoint(new.longitude, new.latitude), 4326);
        --
        -- Get location polygon ID
        --
        new.location_id = (
            select
                location_id
            from
                public.atd_txdot_locations
            where
                location_group = 1 -- level 1-4 polygons
                and st_contains(geometry, new.position)
            limit 1);
        raise notice 'found location: % compared to previous location: %', new.location_id, old.location_id;
        --
        -- Check if in austin full purpose jurisdiction
        --
        new.in_austin_full_purpose =  st_contains((select geometry from atd_jurisdictions where id = 5), new.position);
        raise notice 'in austin full purpose: % compared to previous: %', new.in_austin_full_purpose, old.in_austin_full_purpose;
        --
        -- Get Council District
        --
        new.council_district = (
            select
                council_district
            from
                public.council_districts
            where
                st_contains(geometry, new.position)
            limit 1);
        raise notice 'council_district: % compared to previous: %', new.council_district, old.council_district;
        --
        -- Get engineering area
        --
        new.engineering_area = (
            select
                area_id
            from
                public.engineering_areas
            where
                st_contains(geometry, new.position)
            limit 1);
        raise notice 'engineering_area: % compared to previous: %', new.engineering_area, old.engineering_area;
        else
            raise notice 'setting location id and council district to null';
            -- nullify position column
            new.position = null;
            -- reset location id
            new.location_id = null;
            -- use city ID to determine full purpose jurisdiction
            new.in_austin_full_purpose = coalesce(new.rpt_city_id = 22, false);
            raise notice 'setting in_austin_full_purpose based on city id: %', new.in_austin_full_purpose;
            -- reset council district
            new.council_district = null;
            -- reset engineering area
            new.engineering_area = null;
    end if;
    RETURN NEW;
END;
$$;

create trigger crashes_set_spatial_attributes_on_insert
before insert on public.crashes
for each row
execute procedure public.crashes_set_spatial_attributes();

create trigger crashes_set_spatial_attributes_on_update
before update on public.crashes
for each row
when (
    new.latitude is distinct from old.latitude
    or new.longitude is distinct from old.longitude
)
execute procedure public.crashes_set_spatial_attributes();
