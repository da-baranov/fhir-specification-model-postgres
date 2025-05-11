drop table if exists public.fhir_interactions cascade;

create table public.fhir_interactions 
(
  release                    text not null,
  fhir_version               text not null,
  type                       text not null,
  code                       text not null,
  documentation              text
);

insert into public.fhir_interactions
select 
    a.release                as release,
    rests.fhir_version,
    interactions.*
  from 
    public.fhir_artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:CapabilityStatement/fhir:rest' 
      passing a.file
      columns 
        rest                 xml path '.',
        fhir_version         text path '../fhir:fhirVersion/@value'
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

create index ix_fhir_interactions_release on public.fhir_interactions(release);
create index ix_fhir_interactions_fhir_version on public.fhir_interactions(fhir_version);
create index ix_fhir_interactions_type    on public.fhir_interactions(type);
create index ix_fhir_interactions_code    on public.fhir_interactions(code);