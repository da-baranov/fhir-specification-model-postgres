drop table if exists public.fhir_elements cascade;

create table public.fhir_elements 
(
  release                    text not null,
  owner_id                   text not null,
  id                         text not null,
  name                       text not null,
  kind                       text not null,
  root_owner_id              text not null,
  root_owner_url             text not null, 
  fhir_version               text not null,
  position                   int  not null,
  path                       text not null,
  is_modifier                bool,
  is_summary                 bool,
  short                      text,
  definition                 text,
  comment                    text,
  alias                      text,
  min                        int,
  max                        text
);

insert into public.fhir_elements
select a.release                                  as release,
       regexp_replace(x.id, '\.[^.]+$', '')       as owner_id,
       x.id,
       regexp_replace(x.id, '.*\.(.*?)', '\1')    as name,
       x.kind,
       x.root_owner_id,
       x.root_owner_url,
       x.fhir_version,
       x.position,
       x.path,
       x.is_modifier,
       x.is_summary,
       x.short,
       x.definition,
       x.comment,
       x.alias,
       x.min,
       x.max
  from public.fhir_artifacts a,
  xmltable
  (
     xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition/*/fhir:element' 
     passing a.file
     columns 
       id                    text path '@id',
       kind                  text path 'name(..)',
       root_owner_id         text path '../../fhir:id/@value',
       root_owner_url        text path '../../fhir:url/@value',
       fhir_version          text path '../../fhir:fhirVersion/@value',
       position              int  path 'count(./preceding-sibling::fhir:element)+1',
       path                  text path 'fhir:path/@value',
       is_modifier           bool path 'boolean(fhir:isModifier/@value)',
       is_summary            bool path 'boolean(fhir:isSummary/@value)',
       short                 text path 'fhir:short/@value',
       definition            text path 'fhir:definition/@value',
       comment               text path 'fhir:comment/@value',
       alias                 text path 'fhir:alias[1]/@value',
       min                   int  path 'fhir:min/@value',
       max                   text path 'fhir:max/@value'
) x where a.filename in ('profiles-resources.xml', 'profiles-types.xml', 'profiles-others.xml');

create index ix_fhir_elements_release        on public.fhir_elements(release);
create index ix_fhir_elements_owner_id       on public.fhir_elements(owner_id);
create index ix_fhir_elements_id             on public.fhir_elements(id);
create index ix_fhir_elements_root_owner_id  on public.fhir_elements(root_owner_id);
create index ix_fhir_elements_root_owner_url on public.fhir_elements(root_owner_url);
create index ix_fhir_elements_fhir_version   on public.fhir_elements(fhir_version);
create index ix_fhir_elements_path           on public.fhir_elements(path);
