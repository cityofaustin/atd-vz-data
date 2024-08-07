--
-- handle an $tableName$_edits update by updating the
-- unified $tableName$ record from cris + edit values
--
create or replace function public.$tableName$_edits_update()
returns trigger
language plpgsql
as $$
declare
    new_edits_jb jsonb := to_jsonb (new);
    cris_record_jb jsonb;
    column_name text;
    updates_todo text [] := '{}';
    update_stmt text := 'update public.$tableName$ set ';
begin
    -- get corresponding the cris record as jsonb
    SELECT to_jsonb($tableName$_cris) INTO cris_record_jb from public.$tableName$_cris where public.$tableName$_cris.$pkColumnName$ = new.$pkColumnName$;
    -- for every key in the vz json object
    for column_name in select jsonb_object_keys(new_edits_jb) loop
        -- ignore audit fields, except updated_by
        continue when column_name in ('created_at', 'updated_at', 'created_by');
        --  create a set statement for the column
        if cris_record_jb ? column_name then
            -- if this column exists on the cris table, coalesce vz + cris values
            updates_todo := updates_todo
            || format('%I = coalesce($1.%I, cris_record.%I)', column_name, column_name, column_name);
        else
            updates_todo := updates_todo
            || format('%I = $1.%I', column_name, column_name);
        end if;
    end loop;
    -- join all `set` clauses together
    update_stmt := update_stmt
        || array_to_string(updates_todo, ',')
        || format(' from (select * from public.$tableName$_cris where public.$tableName$_cris.$pkColumnName$ = %s) as cris_record', new.$pkColumnName$)
        || format(' where public.$tableName$.$pkColumnName$ = %s ', new.$pkColumnName$);
    raise debug 'Updating unified $tableName$ record from edit update';
    execute (update_stmt) using new;
    return null;
end;
$$;

create trigger update_$tableName$_from_$tableName$_edits_update
after update on public.$tableName$_edits for each row
execute procedure public.$tableName$_edits_update();
