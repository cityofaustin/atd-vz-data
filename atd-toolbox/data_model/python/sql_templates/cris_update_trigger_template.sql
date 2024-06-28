--
-- handle a cris $tableName$ update by updating the
-- unified $tableName$ record from cris + vz values
--
create or replace function public.$tableName$_cris_update()
returns trigger
language plpgsql
as $$
declare
    new_cris_jb jsonb := to_jsonb (new);
    old_cris_jb jsonb := to_jsonb (old);
    edit_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.$tableName$ set ';
begin
    -- get corresponding the VZ record as jsonb
    SELECT to_jsonb($tableName$_edits) INTO edit_record_jb from public.$tableName$_edits where public.$tableName$_edits.$pkColumnName$ = new.$pkColumnName$;

    -- for every key in the cris json object
    for column_name in select jsonb_object_keys(new_cris_jb) loop
        -- ignore audit fields
        continue when column_name in ('created_at', 'updated_at', 'created_by', 'updated_by');
        -- if the new value doesn't match the old
        if(new_cris_jb -> column_name <> old_cris_jb -> column_name) then
            -- see if the vz record has a value for this field
            if (edit_record_jb ->> column_name is  null) then
                -- this value is not overridden by VZ
                -- so update the unified record with this new value
                updates_todo := updates_todo || format('%I = $1.%I', column_name, column_name);
            end if;
        end if;
    end loop;
    if(array_length(updates_todo, 1) > 0) then
        -- set audit field updated_by to match cris record
        updates_todo := updates_todo || format('%I = $1.%I', 'updated_by', 'updated_by');
        -- complete the update statement by joining all `set` clauses together
        update_stmt := update_stmt
            || array_to_string(updates_todo, ',')
            || format(' where public.$tableName$.$pkColumnName$ = %s', new.$pkColumnName$);
        raise notice 'Updating $tableName$ record from CRIS update';
        execute (update_stmt) using new;
    else
        raise notice 'No changes to unified record needed';
    end if;
    return null;
end;
$$;

create trigger update_$tableName$_from_$tableName$_cris_update
after update on public.$tableName$_cris for each row
execute procedure public.$tableName$_cris_update();
