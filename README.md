# fhir-specification-model-postgres

## Description

This project is designed to transform HL7 FHIR standard release models into a relational form. A PostgreSQL instance is used as the database server.

## Examples

**Select a list of FHIR R4 simple types**

```sql
select t.*
  from fhir.types t
 where t.release = 'R4'
   and t.kind = 'primitive-type'
```

**Select a list of FHIR R4 resources**

```sql
select t.*
  from fhir.types t
 where t.release = 'R4'
   and t.kind = 'resource'
```

**Select a list of FHIR R5 elements of the Patient resource**

```sql
select t.*
  from fhir.elements t
 where t.release = 'R5'
   and t.owner_id = 'Patient'
   and t.kind = 'differential'
 order by t.position
```

**Select a list of possible types of the R5 Encounter.subject element**

```sql
select t.*
  from fhir.element_types t
 where t.release = 'R5'
   and t.kind = 'snapshot'
   and t.id = 'Encounter.subject'
```

**Select a list of R4 Account resource search parameters**

```sql
select * 
  from fhir.search_params 
 where release = 'R4' 
   and base = 'Account'
```

## DDL generation


## Docker support

Not planned.






