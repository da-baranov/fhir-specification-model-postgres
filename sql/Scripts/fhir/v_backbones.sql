create or replace view fhir.v_backbones
as
with tmp as
(
	select t.* as types from xmltable
	(
	  xmlnamespaces('http://hl7.org/fhir' as fhir),
	  '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition/*/fhir:element' 
	  passing (select file from fhir.artifacts where release = 'R4' and filename = 'profiles-resources.xml')
	  columns 
	    id				text path '@id',
	    kind            text path 'name(..)',
	    fhirVersion     text path '../../fhir:fhirVersion/@value',
	    owner_id	    text path '../../fhir:id/@value',
	    owner_url       text path '../../fhir:url/@value',
	    pos             int  path 'count(./preceding-sibling::*)+1',
	    path            text path 'fhir:path/@value',
	    isModifier      bool path 'fhir:isModifier/@value',
	    isSummary       bool path 'fhir:isSummary/@value',
	    short           text path 'fhir:short/@value',
	    definition      text path 'fhir:definition/@value',
	    comment         text path 'fhir:comment/@value',
	    alias           text path 'fhir:alias[1]/@value',
	    min	            text path 'fhir:min/@value',
	    max             text path 'fhir:max/@value',
	    type            text path 'fhir:type[1]/fhir:code/@value'
	) t
)
select backbones.id                        as id,
       null::text                          as url,
       fhir.f_get_short_name(backbones.id) as name,
       null::text                          as status,  
       backbones.definition                as description,
       null::text                          as purpose,
       backbones.fhirVersion               as fhirVersion,
       'backbone'::text                    as kind,
       null::text                          as abstract,
       backbones.id                        as type,
       null::text                          as basedefinition,
       null::text                          as derivation
  from tmp backbones
 where backbones.type = 'BackboneElement'
  
    
  
  