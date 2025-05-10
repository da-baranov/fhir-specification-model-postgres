create or replace function fhir.f_resolve_type(fhirRelease text, url text)
returns text immutable
as
$$
declare
  result text;
begin
  begin
    select t1.id into result 
      from fhir.v_types t1
     where 
       t1.release = fhirRelease
       and t1.url = f_resolve_type.url;
  exception
    when NO_DATA_FOUND then null;
  end;	
  return result;
end
$$ language plpgsql;
