drop table if exists fhir.operations cascade;

create table fhir.operations as
select 
    a.release,
    op.id,
    op.use,
    op.url,
    op.version,
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
    fhir.artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:OperationDefinition' 
      passing a.file
      columns 
        id                   text path 'fhir:id/@value',
        use                  text path 'fhir:extension[@url="http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status"][1]/fhir:valueCode/@value',
        url                  text path 'fhir:url/@value',
        version              text path 'fhir:version/@value',
        name                 text path 'fhir:name/@value',
        title                text path 'fhir:title/@value',
        status               text path 'fhir:status/@value',
        kind                 text path 'fhir:kind/@value',
        experimental         bool path 'boolean(fhir:experimental/@value)',
        description          text path 'fhir:description/@value',
        affects_state        bool path 'boolean(fhir:affectsState/@value)',
        code                 text path 'fhir:code/@value',
        comment              text path 'fhir:comment/@value',
        resource_str         text path 'concat(
                                          fhir:resource[1]/@value,",",
                                          fhir:resource[2]/@value,",",
                                          fhir:resource[3]/@value,",",
                                          fhir:resource[4]/@value,",",
                                          fhir:resource[5]/@value,",",
                                          fhir:resource[6]/@value,",",
                                          fhir:resource[7]/@value,",",
                                          fhir:resource[8]/@value,",",
                                          fhir:resource[9]/@value,",",
                                          fhir:resource[10]/@value,","
                                        )',
        system               bool path 'boolean(fhir:system/@value)',
        type                 bool path 'boolean(fhir:type/@value)',
        instance             bool path 'boolean(fhir:instance/@value)'        
    ) op,
  string_to_table(op.resource_str, ',') as t1(resource)  
  where a.filename = 'profiles-resources.xml'
    and t1.resource is not null
    and t1.resource <> '';

create index ix_operations_id         on fhir.operations(id);
create index ix_operations_release    on fhir.operations(release);
create index ix_operations_name       on fhir.operations(name);
create index ix_operations_code       on fhir.operations(code);
create index ix_operations_resource   on fhir.operations(resource);