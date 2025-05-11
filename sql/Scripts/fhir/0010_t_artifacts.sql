create table if not exists fhir.artifacts 
(
	release   text not null,
	filename  text not null,
	file      xml not null,
	constraint artifacts_pk primary key (release, filename)
);