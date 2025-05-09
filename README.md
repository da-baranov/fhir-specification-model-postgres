# fhir-specification-model-postgres

## Description

This project is designed to transform HL7 FHIR standard release models into a relational form. A PostgreSQL instance is used as the database server.

## Examples

**Select a list of FHIR simple types**

```sql
select t.*
  from fhir.mv_simple_types t
 where t.fhirRelease = 'R4'
```

**Select a list of FHIR elements of the Patient resource**

```sql
select e.*
  from fhir.mv_elements e
 where e.fhirRelease = 'R5'
   and e.owner_id = 'Patient'
 order by e.pos
```




