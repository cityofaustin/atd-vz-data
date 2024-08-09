alter table units drop column vz_mode_category_id;

alter table units add column vz_mode_category_id integer
references lookups.mode_category (id)
on update restrict on delete restrict;
