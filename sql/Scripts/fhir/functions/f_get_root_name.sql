create or replace function fhir.f_get_short_name(id text)
returns text immutable
language plpgsql
as
$$
declare
  result text;
  row    record;
begin
  for row in (select * from string_to_table(id, '.')) loop
  	result := row.string_to_table;
  end loop;
  return result;
end
$$

/*
select fhir.f_get_short_name('aaaa.baaa.caaavvv')
*/