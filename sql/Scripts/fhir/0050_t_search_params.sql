drop table if exists fhir.search_params cascade;

create table fhir.search_params
as
  select 
    a.release              as release,
    x.id,
    x.use,
    x.url,
    x.version,
    x.name,
    x.status,
    x.experimental,
    x.description,
    x.code,
    x.type,
    x.processing_mode,
    t1.*
  from 
  fhir.artifacts a,
  xmltable
  (
    xmlnamespaces('http://hl7.org/fhir' as fhir), '/fhir:Bundle/fhir:entry/fhir:resource/fhir:SearchParameter' 
    passing a.file
    columns 
      id                   text path 'fhir:id/@value',
      use                  text path 'fhir:extension[@url=''http://hl7.org/fhir/StructureDefinition/structuredefinition-standards-status'']/fhir:valueCode/@value',
      url                  text path 'fhir:url/@value',
      version              text path 'fhir:version/@value',
      name                 text path 'fhir:name/@value',
      status               text path 'fhir:status/@value',
      experimental         bool path 'boolean(fhir:experimental/@value)',
      description          text path 'fhir:description/@value',
      code                 text path 'fhir:code/@value',
      base                 text path 'concat(
                                        fhir:base[1]/@value, ",",fhir:base[2]/@value, ",",fhir:base[3]/@value,",",fhir:base[4]/@value,",",fhir:base[5]/@value,",",
                                        fhir:base[6]/@value, ",",fhir:base[7]/@value, ",",fhir:base[8]/@value,",",fhir:base[9]/@value,",",fhir:base[10]/@value,",",
                                        fhir:base[11]/@value,",",fhir:base[12]/@value,",",fhir:base[13]/@value,",",fhir:base[14]/@value,",",fhir:base[15]/@value,",",
                                        fhir:base[16]/@value,",",fhir:base[17]/@value,",",fhir:base[18]/@value,",",fhir:base[19]/@value,",",fhir:base[20]/@value,",",
                                        fhir:base[21]/@value,",",fhir:base[22]/@value,",",fhir:base[23]/@value,",",fhir:base[24]/@value,",",fhir:base[25]/@value,",",
                                        fhir:base[26]/@value,",",fhir:base[27]/@value,",",fhir:base[28]/@value,",",fhir:base[29]/@value,",",fhir:base[30]/@value,",",
                                        fhir:base[31]/@value,",",fhir:base[32]/@value,",",fhir:base[33]/@value,",",fhir:base[34]/@value,",",fhir:base[35]/@value,",",
                                        fhir:base[36]/@value,",",fhir:base[37]/@value,",",fhir:base[38]/@value,",",fhir:base[39]/@value,",",fhir:base[40]/@value,",",
                                        fhir:base[41]/@value,",",fhir:base[42]/@value,",",fhir:base[43]/@value,",",fhir:base[44]/@value,",",fhir:base[45]/@value,",",
                                        fhir:base[46]/@value,",",fhir:base[47]/@value,",",fhir:base[48]/@value,",",fhir:base[49]/@value,",",fhir:base[50]/@value,",",
                                        fhir:base[51]/@value,",",fhir:base[52]/@value,",",fhir:base[53]/@value,",",fhir:base[54]/@value,",",fhir:base[55]/@value,",",
                                        fhir:base[56]/@value,",",fhir:base[57]/@value,",",fhir:base[58]/@value,",",fhir:base[59]/@value,",",fhir:base[60]/@value,",",
                                        fhir:base[61]/@value,",",fhir:base[62]/@value,",",fhir:base[63]/@value,",",fhir:base[64]/@value,",",fhir:base[65]/@value,",",
                                        fhir:base[66]/@value,",",fhir:base[67]/@value,",",fhir:base[68]/@value,",",fhir:base[69]/@value,",",fhir:base[70]/@value,",",
                                        fhir:base[71]/@value,",",fhir:base[72]/@value,",",fhir:base[73]/@value,",",fhir:base[74]/@value,",",fhir:base[75]/@value,",",
                                        fhir:base[76]/@value,",",fhir:base[77]/@value,",",fhir:base[78]/@value,",",fhir:base[79]/@value,",",fhir:base[80]/@value,",",
                                        fhir:base[81]/@value,",",fhir:base[82]/@value,",",fhir:base[83]/@value,",",fhir:base[84]/@value,",",fhir:base[85]/@value,",",
                                        fhir:base[86]/@value,",",fhir:base[87]/@value,",",fhir:base[88]/@value,",",fhir:base[89]/@value,",",fhir:base[90]/@value,",",
                                        fhir:base[91]/@value,",",fhir:base[92]/@value,",",fhir:base[93]/@value,",",fhir:base[94]/@value,",",fhir:base[95]/@value,",",
                                        fhir:base[96]/@value,",",fhir:base[97]/@value,",",fhir:base[98]/@value,",",fhir:base[99]/@value,",",fhir:base[100]/@value
                                      )',
      type                 text path 'fhir:type/@value',
      processing_mode      text path 'fhir:processingMode/@value'
  ) x,
  string_to_table(x.base, ',') as t1(base)
  where a.filename = 'search-parameters.xml'
    and t1.base is not null
    and t1.base <> '';


create index idx_search_params_id   on fhir.search_params(id);
create index idx_search_params_url  on fhir.search_params(url);
create index idx_search_params_name on fhir.search_params(name);
create index idx_search_params_code on fhir.search_params(code);
create index idx_search_params_base on fhir.search_params(base);
create index idx_search_params_type on fhir.search_params(type);