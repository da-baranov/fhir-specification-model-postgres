create or replace function fhir.f_resolve_type(fhirRelease text, url text)
returns text immutable
as
$$
declare
  result text;
begin
  begin
    select t1.id into result 
      from fhir.v_resources t1
     where t1.url = f_resolve_type.url;
  exception
    when NO_DATA_FOUND then
    begin
      select t.id into result 
        from fhir.v_simple_types t
       where t.url = f_resolve_type.url;
    exception
      when NO_DATA_FOUND then null;
    end;
  end;	
  return result;
end
$$ language plpgsql;
