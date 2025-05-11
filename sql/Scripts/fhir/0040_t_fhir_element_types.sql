drop table if exists fhir.fhir_element_types cascade;

create table fhir.fhir_element_types as
with codes as
(
  select a.release,
         x.*
    from fhir.fhir_artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition/*/fhir:element/fhir:type' 
      passing a.file
      columns 
        id                    text path '../@id',
        kind                  text path 'name(../..)',
        code                  text path 'fhir:code[1]/@value'
    ) x
    where a.filename in ('profiles-resources.xml', 'profiles-types.xml')
),
target_profiles as
(
  select a.release,
         x.*
    from fhir.fhir_artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:StructureDefinition/*/fhir:element/fhir:type/fhir:targetProfile' 
      passing a.file
      columns 
        id                    text path '../../@id',
        kind                  text path 'name(../../..)',
        target_profile        text path '@value'
    ) x
    where a.filename in ('profiles-resources.xml', 'profiles-types.xml')
)
select t.release,
       t.id,
       t.kind,
       case
         when t.code = 'http://hl7.org/fhirpath/System.String'    then 'string'
         when t.code = 'http://hl7.org/fhirpath/System.DateTime'  then 'dateTime'
         when t.code = 'http://hl7.org/fhirpath/System.Time'      then 'time'
         when t.code = 'http://hl7.org/fhirpath/System.Date'      then 'date'
         when t.code = 'http://hl7.org/fhirpath/System.Boolean'   then 'boolean'
         when t.code = 'http://hl7.org/fhirpath/System.Integer'   then 'integer'
         when t.code = 'http://hl7.org/fhirpath/System.Decimal'   then 'decimal'
         else t.code
       end as code,
       t1.target_profile,
       regexp_replace(t1.target_profile, '.*\/(.*?)', '\1') as target_resource
  from codes t
  left join target_profiles t1
    on (t.id = t1.id and t.release = t1.release and t.kind = t1.kind);
  

create index ix_fhir_element_types_types_release         on fhir.fhir_element_types(release);
create index ix_fhir_element_types_types_id              on fhir.fhir_element_types(id);
create index ix_fhir_element_types_types_kind            on fhir.fhir_element_types(kind);
create index ix_fhir_element_types_types_code            on fhir.fhir_element_types(code);
create index ix_fhir_element_types_types_target_profile  on fhir.fhir_element_types(target_profile);
create index ix_fhir_element_types_types_target_resource on fhir.fhir_element_types(target_resource);