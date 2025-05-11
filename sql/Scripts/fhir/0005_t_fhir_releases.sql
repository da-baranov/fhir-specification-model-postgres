create table if not exists public.fhir_releases
(
  release text not null,
  version text not null
);
create unique index if not exists ix_fhir_releases on public.fhir_releases (release, version);
insert into public.fhir_releases(release, version) values('R4', '4.0.1') on conflict do nothing;
insert into public.fhir_releases(release, version) values('R4B', '4.3.0') on conflict do nothing;
insert into public.fhir_releases(release, version) values('R5', '5.0.0') on conflict do nothing;