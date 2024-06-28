create or replace function public.$tableName$_cris_insert_rows()
returns trigger
language plpgsql
as
$$
BEGIN
    -- insert new combined / official record
    INSERT INTO public.$tableName$ ($affectedColumns$) values (
        $affectedColumnsWithNewPrefix$
    );
    -- insert new (editable) vz record (only record ID)
    INSERT INTO public.$tableName$_edits ($pkColumnName$) values (new.$pkColumnName$);

    RETURN NULL;
END;
$$;


create or replace trigger insert_new_$tableName$_cris
after insert on public.$tableName$_cris
for each row
execute procedure public.$tableName$_cris_insert_rows();
