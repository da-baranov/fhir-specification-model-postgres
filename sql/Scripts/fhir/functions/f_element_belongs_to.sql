create or replace function fhir.f_element_belongs_to(id text, elementId text)
returns boolean immutable
language plpgsql
as
$$
begin
  return starts_with(elementId, id) 
         and 
         (
           array_length(string_to_array(id, '.'), 1) + 1    = 
           array_length(string_to_array(elementId, '.'), 1)
         );
end
$$

/* 
select fhir.f_element_belongs_to('a', 'a.d')
*/


