drop table if exists public.fhir_operation_params cascade;

create table public.fhir_operation_params
(
  release                    text not null,
  fhir_version               text not null,
  id                         text not null,
  name                       text not null,
  position                   int  not null,
  use                        text,
  min                        int,
  max                        text,
  documentation              text,
  search_type                text,
  resource                   text not null
);

insert into public.fhir_operation_params
select 
    a.release,
    p.fhir_version,
    p.id,
    p.name,
    p.position,
    p.use,
    p.min,
    p.max,
    p.documentation,
    p.search_type,
    t1.resource
  from 
    public.fhir_artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:OperationDefinition/fhir:parameter' 
      passing a.file
      columns 
        fhir_version         text path '../fhir:version/@value',
        id                   text path '../fhir:id/@value',
        position             int  path 'count(./preceding-sibling::fhir:parameter)+1',
        name                 text path 'fhir:name/@value',
        use                  text path 'fhir:use/@value',
        min                  int  path 'fhir:min/@value',
        max                  text path 'fhir:max/@value',
        documentation        text path 'fhir:documentation/@value',
        search_type          text path 'fhir:searchType/@value',
        op                   xml  path '..'
    ) p,
  unnest(xpath('/fhir:OperationDefinition/fhir:resource/@value', p.op, ARRAY[ARRAY['fhir', 'http://hl7.org/fhir']])) as t1(resource) 
  where a.filename = 'profiles-resources.xml';

create index ix_fhir_operation_params_release    on public.fhir_operation_params(release);
create index ix_fhir_operation_params_fhir_version    on public.fhir_operation_params(fhir_version);
create index ix_fhir_operation_params_id         on public.fhir_operation_params(id);
create index ix_fhir_operation_params_name       on public.fhir_operation_params(name);
create index ix_fhir_operation_params_resource   on public.fhir_operation_params(resource);
