drop view if exists fhir.v_simple_types;

create or replace view fhir.v_simple_types
as
select 
  a.release,
  x.*
from 
fhir.artifacts a,
xmltable
(
  xmlnamespaces('http://hl7.org/fhir' as fhir),
  '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition' 
  passing a.file
  columns 
    id				text path 'fhir:id/@value',
    url				text path 'fhir:url/@value',
    name			text path 'fhir:name/@value',
    status			text path 'fhir:status/@value',
    description		text path 'fhir:description/@value',
    fhirVersion		text path 'fhir:fhirVersion/@value',
    kind			text path 'fhir:kind/@value',
    abstract		text path 'fhir:abstract/@value',
    type 			text path 'fhir:type/@value',
    baseDefinition  text path 'fhir:baseDefinition/@value',
    derivation      text path 'fhir:derivation/@value'
) x
where 
  a.filename = 'profiles-types.xml'