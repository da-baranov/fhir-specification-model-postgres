drop table if exists public.fhir_search_params cascade;

create table public.fhir_search_params
(
  release                    text not null,
  id                         text not null,
  use                        text not null,
  url                        text not null,
  fhir_version               text not null,
  name                       text not null,
  status                     text not null,
  experimental               bool default false,
  description                text,
  code                       text not null,
  type                       text not null,
  processing_mode            text,
  expression                 text,
  multiple_and               bool default false,
  multiple_or                bool default false,
  comparator                 text[],
  base                       text
);

insert into public.fhir_search_params
  select 
    a.release                as release,
    x.id,
    x.use,
    x.url,
    x.version                as fhir_version,
    x.name,
    x.status,
    x.experimental,
    x.description,
    x.code,
    x.type,
    x.processing_mode,
    x.expression,
    x.multiple_and,
    x.multiple_or,
    xpath('/fhir:SearchParameter/fhir:comparator/@value', x.comparator, ARRAY[ARRAY['fhir', 'http://hl7.org/fhir']]),
    t1.base
  from 
  public.fhir_artifacts a,
  xmltable
  (
    xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:SearchParameter' 
    passing a.file
    columns 
      id                   text path 'fhir:id/@value',
      use                  text path 'fhir:extension[@url=''http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status'']/fhir:valueCode/@value',
      url                  text path 'fhir:url/@value',
      version              text path 'fhir:version/@value',
      name                 text path 'fhir:name/@value',
      status               text path 'fhir:status/@value',
      experimental         bool path 'boolean(fhir:experimental/@value)',
      description          text path 'fhir:description/@value',
      code                 text path 'fhir:code/@value',
      type                 text path 'fhir:type/@value',
      processing_mode      text path 'fhir:processingMode/@value',
      expression           text path 'fhir:expression/@value',
      multiple_and         bool path 'boolean(fhir:multipleAnd/@value)',
      multiple_or          bool path 'boolean(fhir:multipleOr/@value)',
      comparator           xml  path '.'
  ) x,
  unnest(xpath('/fhir:SearchParameter/fhir:base/@value', x.comparator, ARRAY[ARRAY['fhir', 'http://hl7.org/fhir']])) as t1(base)
  where a.filename = 'search-parameters.xml';


create index idx_fhir_search_params_id   on public.fhir_search_params(id);
create index idx_fhir_search_params_url  on public.fhir_search_params(url);
create index idx_fhir_search_params_name on public.fhir_search_params(name);
create index idx_fhir_search_params_fhir_version on public.fhir_search_params(fhir_version);
create index idx_fhir_search_params_code on public.fhir_search_params(code);
create index idx_fhir_search_params_base on public.fhir_search_params(base);
create index idx_fhir_search_params_type on public.fhir_search_params(type);