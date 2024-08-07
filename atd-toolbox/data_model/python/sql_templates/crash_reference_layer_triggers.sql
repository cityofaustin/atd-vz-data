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
        -- get location polygon id
        --
        if (new.rpt_road_part_id != 2 and upper(ltrim(new.rpt_hwy_num)) in ('35', '183','183A','1','290','71','360','620','45','130')) then
            -- use level 5 polygon
            new.location_id = (
                select
                    location_id
                from
                    public.atd_txdot_locations
                where
                    location_group = 2 -- level 5
                    and st_contains(geometry, new.position)
                limit 1);
        else
            -- use the other polygons
            new.location_id = (
                select
                    location_id
                from
                    public.atd_txdot_locations
                where
                    location_group = 1 -- not level 5
                    and st_contains(geometry, new.position)
                limit 1);
        end if;

        raise debug 'found location: % compared to previous location: %', new.location_id, old.location_id;
        --
        -- check if in austin full purpose jurisdiction
        --
        new.in_austin_full_purpose =  st_contains((select geometry from atd_jurisdictions where id = 5), new.position);
        raise debug 'in austin full purpose: % compared to previous: %', new.in_austin_full_purpose, old.in_austin_full_purpose;
        --
        -- get council district
        --
        new.council_district = (
            select
                council_district
            from
                public.council_districts
            where
                st_contains(geometry, new.position)
            limit 1);
        raise debug 'council_district: % compared to previous: %', new.council_district, old.council_district;
        --
        -- get engineering area
        --
        new.engineering_area = (
            select
                area_id
            from
                public.engineering_areas
            where
                st_contains(geometry, new.position)
            limit 1);
        raise debug 'engineering_area: % compared to previous: %', new.engineering_area, old.engineering_area;
        else
            raise debug 'setting location id and council district to null';
            -- nullify position column
            new.position = null;
            -- reset location id
            new.location_id = null;
            -- use city id to determine full purpose jurisdiction
            new.in_austin_full_purpose = coalesce(new.rpt_city_id = 22, false);
            raise debug 'setting in_austin_full_purpose based on city id: %', new.in_austin_full_purpose;
            -- reset council district
            new.council_district = null;
            -- reset engineering area
            new.engineering_area = null;
    end if;
    return new;
end;
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
