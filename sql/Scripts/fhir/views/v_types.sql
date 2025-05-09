drop view if exists fhir.v_types;

create or replace view fhir.v_types
as

/* SIMPLE AND COMPLEX TYPES */
(
	select 
	  a.release,
	  x.*,
	  null::text         as owner_type_id,
	  null::text         as root_type_id
	from 
	fhir.artifacts a,
	xmltable
	(
	  xmlnamespaces('http://hl7.org/fhir' as fhir),
	  '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition' 
	  passing a.file
	  columns 
	    id							 text path 'fhir:id/@value',
	    url							 text path 'fhir:url/@value',
	    name						 text path 'fhir:name/@value',
	    status					 text path 'fhir:status/@value',
	    description			 text path 'fhir:description/@value',
	    purpose          text path 'fhir:purpose/@value',
	    fhir_version     text path 'fhir:fhirVersion/@value',
	    kind						 text path 'fhir:kind/@value',
	    abstract		     text path 'fhir:abstract/@value',
	    type 			       text path 'fhir:type/@value',
	    base_definition  text path 'fhir:baseDefinition/@value',
	    derivation       text path 'fhir:derivation/@value'
	) x
	where 
	  a.filename = 'profiles-types.xml'
)
  
union

/* RESOURCES */
(
	select
	  a.release,
	  x.*,
	  null::text         as owner_type_id,
    null::text         as root_type_id
	  from fhir.artifacts a,
	xmltable
	(
	  xmlnamespaces('http://hl7.org/fhir' as fhir),
	  '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition' 
	  passing a.file
	  columns 
	    id				       text path 'fhir:id/@value',
	    url				       text path 'fhir:url/@value',
	    name			       text path 'fhir:name/@value',
	    status			     text path 'fhir:status/@value',
	    description		   text path 'fhir:description/@value',
	    purpose 		     text path 'fhir:purpose/@value',
	    fhir_version	   text path 'fhir:fhirVersion/@value',
	    kind			       text path 'fhir:kind/@value',
	    abstract		     text path 'fhir:abstract/@value',
	    type 			       text path 'fhir:type/@value',
	    base_definition  text path 'fhir:baseDefinition/@value',
	    derivation       text path 'fhir:derivation/@value'
	) x
	where a.filename = 'profiles-resources.xml'
)

union 

/* BACKBONES */
(
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
		    id				     text path '@id',
		    kind           text path 'name(..)',
		    fhir_version   text path '../../fhir:fhirVersion/@value',
		    path           text path 'fhir:path/@value',
		    short          text path 'fhir:short/@value',
		    definition     text path 'fhir:definition/@value',
		    comment        text path 'fhir:comment/@value',
		    type           text path 'fhir:type[1]/fhir:code/@value'
		) x
		where a.filename = 'profiles-resources.xml'
	)
	select backbones.release                               as release,
	       backbones.id                                    as id,
	       null::text                                      as url,
	       regexp_replace(backbones.id, '.*\.(.*?)', '\1') as name,
	       null::text                                      as status,  
	       backbones.definition                            as description,
	       null::text                                      as purpose,
	       backbones.fhir_version                          as fhir_version,
	       'backbone'::text                                as kind,
	       'false'::text                                   as abstract,
	       backbones.id                                    as type,
	       null::text                                      as base_definition,
	       null::text                                      as derivation,
         regexp_replace(backbones.id, '\.[^.]+$', '')    as owner_type_id, -- for ValueSet.compose.include.concept.designation -> ValueSet.compose.include.concept
         regexp_substr(backbones.id, '^([^.]+)')         as root_type_id   -- for ValueSet.compose.include.concept.designation -> ValueSet
	  from tmp backbones
	 where backbones.type = 'BackboneElement'
)

