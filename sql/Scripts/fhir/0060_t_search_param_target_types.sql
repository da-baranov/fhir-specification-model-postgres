drop table if exists fhir.search_param_target_types cascade;

create table fhir.search_param_target_types
as
  select 
    a.release              as release,
    x.id                   as id,
    x.target               as target
  from 
  fhir.artifacts a,
  xmltable
  (
    xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:SearchParameter/fhir:target' 
    passing a.file
    columns 
      id                   text path '../fhir:id/@value',
      target               text path '@value'
  ) x
  where a.filename = 'search-parameters.xml';

create index idx_search_param_target_types_release on fhir.search_param_target_types(release);
create index idx_search_param_target_types_id on fhir.search_param_target_types(id);
create index idx_search_param_target_types_target on fhir.search_param_target_types(target);