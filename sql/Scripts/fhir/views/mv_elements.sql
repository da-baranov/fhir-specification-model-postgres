drop materialized view if exists fhir.mv_elements cascade;

create materialized view fhir.mv_elements as select * from fhir.v_elements;