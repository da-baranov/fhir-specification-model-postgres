drop view if exists fhir.v_elements cascade;

create or replace view fhir.v_elements as
select a.release                                  as release,
       fhir.f_extract_types(x.xml)                as types,
       regexp_replace(x.id, '\.[^.]+$', '')       as owner_id,
       x.*
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
       max                   text path 'fhir:max/@value',
       xml                   xml  path '.'
) x where a.filename = 'profiles-types.xml'