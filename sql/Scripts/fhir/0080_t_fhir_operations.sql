drop table if exists public.fhir_operations cascade;

create table public.fhir_operations
(
  release                    text not null,
  id                         text not null,
  use                        text,
  url                        text not null,
  fhir_version               text not null,
  name                       text not null,
  title                      text,
  status                     text,
  kind                       text,
  experimental               bool,
  description                text,
  affects_state              bool,
  code                       text not null,
  comment                    text,
  resource                   text not null,
  system                     bool,
  type                       bool,
  instance                   bool
);

insert into public.fhir_operations
select 
    a.release,
    op.id,
    op.use,
    op.url,
    op.fhir_version,
    op.name,
    op.title,
    op.status,
    op.kind,
    op.experimental,
    op.description,
    op.affects_state,
    op.code,
    op.comment,
    t1.resource,
    op.system,
    op.type,
    op.instance
  from 
    public.fhir_artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:OperationDefinition' 
      passing a.file
      columns 
        id                   text path 'fhir:id/@value',
        use                  text path 'fhir:extension[@url="http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status"][1]/fhir:valueCode/@value',
        url                  text path 'fhir:url/@value',
        fhir_version         text path 'fhir:version/@value',
        name                 text path 'fhir:name/@value',
        title                text path 'fhir:title/@value',
        status               text path 'fhir:status/@value',
        kind                 text path 'fhir:kind/@value',
        experimental         bool path 'boolean(fhir:experimental/@value)',
        description          text path 'fhir:description/@value',
        affects_state        bool path 'boolean(fhir:affectsState/@value)',
        code                 text path 'fhir:code/@value',
        comment              text path 'fhir:comment/@value',
        system               bool path 'boolean(fhir:system/@value)',
        type                 bool path 'boolean(fhir:type/@value)',
        instance             bool path 'boolean(fhir:instance/@value)',
        self                 xml  path '.'
    ) op,
  unnest(xpath('/fhir:OperationDefinition/fhir:resource/@value', op.self, ARRAY[ARRAY['fhir', 'http://hl7.org/fhir']])) as t1(resource)  
  where a.filename = 'profiles-resources.xml';


create index ix_fhir_operations_id         on public.fhir_operations(id);
create index ix_fhir_operations_release    on public.fhir_operations(release);
create index ix_fhir_operations_fhir_version    on public.fhir_operations(fhir_version);
create index ix_fhir_operations_name       on public.fhir_operations(name);
create index ix_fhir_operations_code       on public.fhir_operations(code);
create index ix_fhir_operations_resource   on public.fhir_operations(resource);