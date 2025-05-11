drop table if exists fhir.types cascade;

create table fhir.types
as

/* SIMPLE AND COMPLEX TYPES */
(
	select 
	  a.release                as release,
	  x.*,
	  null::text               as owner_type_id,
	  null::text               as root_type_id,
	  false                    as others
	  
	from 
	fhir.artifacts a,
	xmltable
	(
	  xmlnamespaces('http://hl7.org/fhir' as fhir, 'http://www.w3.org/1999/xhtml' as xhtml), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition' 
	  passing a.file
	  columns 
	    id                     text path 'fhir:id/@value',
	    url                    text path 'fhir:url/@value',
	    name                   text path 'fhir:name/@value',
	    status                 text path 'fhir:status/@value',
	    description            text path 'fhir:description/@value',
	    purpose                text path 'fhir:purpose/@value',
	    fhir_version           text path 'fhir:fhirVersion/@value',
	    kind                   text path 'fhir:kind/@value',
      abstract               bool path 'boolean(fhir:abstract/@value)',
	    type                   text path 'fhir:type/@value',
	    base_definition        text path 'fhir:baseDefinition/@value',
	    derivation             text path 'fhir:derivation/@value'
	    -- , "text"            text path 'fhir:text/xhtml:div'
	) x
	where a.filename = 'profiles-types.xml'
)
  
union all

/* RESOURCES */
(
	select
	  a.release,
	  x.*,
    null::text               as owner_type_id,
    null::text               as root_type_id,
    case 
      when a.filename = 'profiles-resources.xml' then true
      else false  
    end                      as others
    from fhir.artifacts a,
	xmltable
	(
	  xmlnamespaces('http://hl7.org/fhir' as fhir, 'http://www.w3.org/1999/xhtml' as xhtml), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition' 
	  passing a.file
	  columns 
      id                     text path 'fhir:id/@value',
      url                    text path 'fhir:url/@value',
      name                   text path 'fhir:name/@value',
      status                 text path 'fhir:status/@value',
      description            text path 'fhir:description/@value',
      purpose                text path 'fhir:purpose/@value',
      fhir_version           text path 'fhir:fhirVersion/@value',
      kind                   text path 'fhir:kind/@value',
      abstract               bool path 'boolean(fhir:abstract/@value)',
      type                   text path 'fhir:type/@value',
      base_definition        text path 'fhir:baseDefinition/@value',
      derivation             text path 'fhir:derivation/@value'
      -- , "text"            xml  path 'fhir:text/xhtml:div'
	) x
	where a.filename in ('profiles-resources.xml', 'profiles-others.xml')
)

union all

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
		         xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition/*/fhir:element' 
		         passing a.file
		         columns 
               id            text path '@id',
               kind          text path 'name(..)',
               fhir_version  text path '../../fhir:fhirVersion/@value',
               path          text path 'fhir:path/@value',
               short         text path 'fhir:short/@value',
               definition    text path 'fhir:definition/@value',
               comment       text path 'fhir:comment/@value',
               type          text path 'fhir:type[1]/fhir:code/@value'
               -- , "text"   xml  path 'fhir:dummy'
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
	       false                                           as abstract,
	       backbones.id                                    as type,
	       null::text                                      as base_definition,
	       null::text                                      as derivation,
	       -- null                                            as "text",
         regexp_replace(backbones.id, '\.[^.]+$', '')    as owner_type_id, -- for ValueSet.compose.include.concept.designation -> ValueSet.compose.include.concept
         regexp_substr(backbones.id, '^([^.]+)')         as root_type_id,  -- for ValueSet.compose.include.concept.designation -> ValueSet
         false                                           as others
	  from tmp backbones
	 where backbones.type = 'BackboneElement'
);

create index ix_types_release on fhir.types(release);
create index ix_types_fhir_version on fhir.types(fhir_version);
create index ix_types_id on fhir.types(id);
create index ix_types_url on fhir.types(url);
create index ix_types_name on fhir.types(name);
create index ix_types_owner_type_id on fhir.types(owner_type_id);
create index ix_types_root_type_id on fhir.types(root_type_id);

