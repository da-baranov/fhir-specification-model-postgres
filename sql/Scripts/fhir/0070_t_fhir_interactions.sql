drop table if exists fhir.fhir_interactions cascade;

create table fhir.fhir_interactions as
select 
    a.release                as release,
    interactions.*
  from 
    fhir.fhir_artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:CapabilityStatement/fhir:rest' 
      passing a.file
      columns 
        rest                 xml path '.'
    ) rests,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:rest/fhir:resource/fhir:interaction'
      passing rests.rest
      columns
        type                 text path '../fhir:type/@value',
        code                 text path 'fhir:code/@value',
        documentation        text path 'fhir:documentation/@value'
    ) interactions
  where a.filename = 'profiles-resources.xml';

create index ix_fhir_interactions_release on fhir.fhir_interactions(release);
create index ix_fhir_interactions_type    on fhir.fhir_interactions(type);
create index ix_fhir_interactions_code    on fhir.fhir_interactions(code);