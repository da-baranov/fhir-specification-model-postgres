drop table if exists fhir.elements cascade;

create table fhir.elements as
select a.release                                  as release,
       regexp_replace(x.id, '\.[^.]+$', '')       as owner_id,
       x.id,
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
  from fhir.artifacts a,
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
       position              int  path 'count(./preceding-sibling::*)+1',
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

create index ix_elements_release on fhir.elements(release);
create index ix_elements_owner_id on fhir.elements(owner_id);
create index ix_elements_id on fhir.elements(id);
create index ix_elements_root_owner_id on fhir.elements(root_owner_id);
create index ix_elements_root_owner_url on fhir.elements(root_owner_url);
create index ix_elements_fhir_version on fhir.elements(fhir_version);
create index ix_elements_path on fhir.elements(path);
