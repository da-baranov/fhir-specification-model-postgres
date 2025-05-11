create table if not exists fhir.fhir_artifacts 
(
	release    text not null,
	filename   text not null,
	file       xml not null,
	constraint fhir_artifacts_pk primary key (release, filename)
);