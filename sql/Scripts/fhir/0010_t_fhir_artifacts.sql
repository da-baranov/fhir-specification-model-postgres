create table if not exists public.fhir_artifacts 
(
	release    text not null,
	filename   text not null,
	file       xml not null,
	constraint fhir_artifacts_pk primary key (release, filename)
);