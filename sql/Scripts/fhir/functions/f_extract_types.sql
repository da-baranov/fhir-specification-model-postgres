create or replace function fhir.f_extract_types(value xml)
returns text[]
as
$$
declare
  row            record;
  row1           record;
  result         text[];
  id             text;
  code           text;
begin
  if value is null then
    return null;
  end if;

  create temp table if not exists tmp as
  select * 
    from 
    xmltable
    (
      xmlnamespaces('http://hl7.org/fhir' as fhir),
      '/fhir:element/fhir:type' 
      passing value
      columns 
        code            text  path 'fhir:code/@value',
        targetProfiles  text  path 'concat(
                                      fhir:targetProfile[1]/@value,"|",
                                      fhir:targetProfile[2]/@value,"|",
                                      fhir:targetProfile[3]/@value,"|",
                                      fhir:targetProfile[4]/@value,"|",
                                      fhir:targetProfile[5]/@value,"|",
									  fhir:targetProfile[6]/@value,"|",
                                      fhir:targetProfile[7]/@value,"|",
                                      fhir:targetProfile[8]/@value,"|",
                                      fhir:targetProfile[9]/@value,"|",
                                      fhir:targetProfile[10]/@value,"|",
                                      fhir:targetProfile[11]/@value,"|",
                                      fhir:targetProfile[12]/@value
                                    )'
    );

  for row in (select * from tmp)
  loop
    if (row.targetProfiles is null) or (row.targetProfiles = '') or (row.targetProfiles = '|||||||||||') then
      code := row.code;
      if (code = 'http://hl7.org/fhirpath/System.String') then 
        code := 'string';
      elsif (code = 'http://hl7.org/fhirpath/System.DateTime') then
        code := 'dateTime';
      elsif (code = 'http://hl7.org/fhirpath/System.Time') then
        code := 'time';
      elsif (code = 'http://hl7.org/fhirpath/System.Date') then
        code := 'date';
      elsif (code = 'http://hl7.org/fhirpath/System.Boolean') then
        code := 'boolean';
      elsif (code = 'http://hl7.org/fhirpath/System.Integer') then
        code := 'integer';
      elsif (code = 'http://hl7.org/fhirpath/System.Decimal') then
        code := 'decimal';
      end if;
      result = array_append(result, code);
    else
      for row1 in 
      (
        select * from string_to_table(row.targetProfiles, '|', null) 
         where string_to_table <> ''
      )
      loop
        id := fhir.f_resolve_type('R4', row1.string_to_table);
        if (id is not null) then
          result = array_append(result, 'Reference(' || id || ')');
        end if;
      end loop;
    end if;
  end loop; 

  drop table tmp;
  return result;
end
$$ language plpgsql

/*
select fhir.f_extract_types('<element xmlns="http://hl7.org/fhir"><type><code value="Reference"/>
              <targetProfile value="http://hl7.org/fhir/StructureDefinition/Patient"/>
              <targetProfile value="http://hl7.org/fhir/StructureDefinition/Group"/></type>
              <type><code value="Patient"/></type></element>'::xml)
              
select fhir.f_extract_types('<element xmlns="http://hl7.org/fhir">
  <type>
    <code value="Reference"/>
    <targetProfile value="http://hl7.org/fhir/StructureDefinition/Patient"/>
  </type></element>'::xml)
*/