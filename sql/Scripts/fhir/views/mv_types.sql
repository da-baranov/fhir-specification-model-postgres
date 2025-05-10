drop materialized view if exists fhir.mv_typess;

create materialized view fhir.mv_types as select * from fhir.v_types;