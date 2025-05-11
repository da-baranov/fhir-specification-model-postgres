drop table if exists public.fhir_search_param_target_types cascade;

create table public.fhir_search_param_target_types
(
  release                    text not null,
  id                         text not null,
  target                     text not null,
  fhir_version               text not null
);

insert into public.fhir_search_param_target_types
  select 
    a.release              as release,
    x.id                   as id,
    x.target               as target,
    x.fhir_version         as fhir_version
  from 
  public.fhir_artifacts a,
  xmltable
  (
    xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:SearchParameter/fhir:target' 
    passing a.file
    columns 
      id                   text path '../fhir:id/@value',
      target               text path '@value',
      fhir_version         text path '../fhir:version/@value'
  ) x
  where a.filename = 'search-parameters.xml';

create index idx_fhir_search_param_target_types_release on public.fhir_search_param_target_types(release);
create index idx_fhir_search_param_target_types_fhir_version on public.fhir_search_param_target_types(fhir_version);
create index idx_fhir_search_param_target_types_id      on public.fhir_search_param_target_types(id);
create index idx_fhir_search_param_target_types_target  on public.fhir_search_param_target_types(target);