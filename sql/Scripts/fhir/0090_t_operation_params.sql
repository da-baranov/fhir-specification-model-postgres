drop table if exists fhir.operation_params cascade;

create table fhir.operation_params as
select 
    a.release,
    p.id,
    p.name,
    p.position,
    p.use,
    p.min,
    p.max,
    p.documentation,
    p.search_type,
    t1.resource
  from 
    fhir.artifacts a,
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:OperationDefinition/fhir:parameter' 
      passing a.file
      columns 
        id                   text path '../fhir:id/@value',
        position             int  path 'count(./preceding-sibling::fhir:parameter)+1',
        resource_str         text path 'concat(
                                          ../fhir:resource[1]/@value,",",
                                          ../fhir:resource[2]/@value,",",
                                          ../fhir:resource[3]/@value,",",
                                          ../fhir:resource[4]/@value,",",
                                          ../fhir:resource[5]/@value,",",
                                          ../fhir:resource[6]/@value,",",
                                          ../fhir:resource[7]/@value,",",
                                          ../fhir:resource[8]/@value,",",
                                          ../fhir:resource[9]/@value,",",
                                          ../fhir:resource[10]/@value,","
                                        )',
        name                 text path 'fhir:name/@value',
        use                  text path 'fhir:use/@value',
        min                  int  path 'fhir:min/@value',
        max                  text path 'fhir:max/@value',
        documentation        text path 'fhir:documentation/@value',
        search_type          text path 'fhir:searchType/@value'
    ) p,
  string_to_table(p.resource_str, ',') as t1(resource)  
  where a.filename = 'profiles-resources.xml'
    and t1.resource is not null
    and t1.resource <> '';

create index ix_operation_params_release    on fhir.operation_params(release);
create index ix_operation_params_id         on fhir.operation_params(id);
create index ix_operation_params_name       on fhir.operation_params(name);
create index ix_operation_params_resource   on fhir.operation_params(resource);
