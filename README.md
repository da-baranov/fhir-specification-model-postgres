# fhir-specification-model-postgres

## Description

The object model of the HL7 FHIR standard is quite complex to study and understand. On the internet, you can find several SDKs for working with the FHIR standard object model (Firely SDK for the .NET platform, HAPI SDK for the Java platform, fhir.resources for Python), but they all use FHIR artifacts in JSON format as their metadata source, which results in relatively low performance.

This project is designed to transform the core classes of the HL7 FHIR object model (simple data types, complex data types, elements, search parameters, operations, and FHIR interactions) into a simplified relational format. This can be useful for educational purposes as well as for developing applications that require fast access to FHIR specification metadata.

Supported FHIR releases: R4, R4B, R5.

## Examples

**Get a list of FHIR R4 primitive types**

```sql
select t.*
  from fhir_types t
 where t.release = 'R4'
   and t.kind = 'primitive-type'
```

**Get a list of FHIR R4 resources**

```sql
select t.*
  from fhir_types t
 where t.release = 'R4'
   and t.kind = 'resource'
   and t.others = false
```

**Get a list of FHIR R5 elements of the Patient resource**

```sql
select t.*
  from fhir_elements t
 where t.release = 'R5'
   and t.owner_id = 'Patient'
   and t.kind = 'differential'
 order by t.position
```

**Get a list of possible types of the R5 Encounter.subject element**

```sql
select t.*
  from fhir_element_types t
 where t.release = 'R5'
   and t.kind = 'snapshot'
   and t.id = 'Encounter.subject'
```

**Get a list of R4 Account resource search parameters**

```sql
select * 
  from fhir_search_params 
 where release = 'R4' 
   and base = 'Account'
```

## Database schema generation

1. Install python3
2. Run pip: `pip install -r requirements.txt`
3. Create an .env file by copying the `env.example` configuration file
4. In the .env configuration file, specify the connection string to your Postgres database
5. In the .env configuration file, specify the name of the schema in your database where new tables will be created (e.g. `fhir` or `public`)
6. Run the script for execution: `python3 main.py`
7. After the script execution is complete, review the objects that were created in your database.

**Important** The script requires an internet connection because it needs to download specifications from the official FHIR website.


## Docker support

Not planned.






