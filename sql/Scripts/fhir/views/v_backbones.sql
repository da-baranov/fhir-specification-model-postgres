drop view if exists fhir.v_backbones;

create or replace view fhir.v_backbones
as
with tmp as
	(
	  select
		a.release,
		x.*
		from fhir.artifacts a,
		xmltable
		(
		  xmlnamespaces('http://hl7.org/fhir' as fhir),
		  '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition/*/fhir:element' 
		  passing a.file
		  columns 
		    id				text path '@id',
		    kind            text path 'name(..)',
		    fhir_version    text path '../../fhir:fhirVersion/@value',
		    path            text path 'fhir:path/@value',
		    short           text path 'fhir:short/@value',
		    definition      text path 'fhir:definition/@value',
		    comment         text path 'fhir:comment/@value',
		    type            text path 'fhir:type[1]/fhir:code/@value'
		) x
		where a.filename = 'profiles-resources.xml'
	)
	select backbones.id                        as id,
	       null::text                          as url,
	       fhir.f_get_short_name(backbones.id) as name,
	       null::text                          as status,  
	       backbones.definition                as description,
	       null::text                          as purpose,
	       backbones.fhir_version              as fhir_version,
	       'backbone'::text                    as kind,
	       null::text                          as abstract,
	       backbones.id                        as type,
	       null::text                          as base_definition,
	       null::text                          as derivation
	  from tmp backbones
	 where backbones.type = 'BackboneElement'
  
    
  
  