drop function if exists dart_generator;
drop function if exists dart_generate_class;
drop function if exists dart_camel_case;

create or replace function dart_camel_case(value text)
returns text
language plpgsql
as
$$
begin
  return
    replace(
      initcap(
        replace(value, '_', ' ')
      ),
      ' ', ''
    );
end
$$;


create or replace function dart_generate_class(table_name text)
returns text
language plpgsql
as
$$
declare
  result text;
  cr     text;
  row    record;
  name   text;
  tp     text;
  dv     text;
begin
  cr := chr(10);
  
  result := '';
  result := result || 'class FE' || dart_camel_case(table_name) || ' extends FEDocument implements ChangeNotifier' || cr;
  result := result || '{' || cr;
  
  for row in  
  (
    select c.*
      from information_schema.tables t
      join information_schema.columns c 
        on t.table_name = c.table_name
     where t.table_name = dart_generate_class.table_name
     order by c.ordinal_position
  )
  loop
    name := row.column_name;
    tp := case 
      when row.data_type = 'text' then 'String'
      when row.data_type = 'varchar' then 'String'
      when row.data_type = 'bool' then 'bool'
      when row.data_type = 'boolean' then 'bool'
      when row.data_type = 'integer' then 'int'
      else 'String'
    end;
    if (row.is_nullable = 'YES') then
      tp := tp || '?';
      dv := '';
    else
      dv := case 
        when row.data_type = 'text' then '""'
        when row.data_type = 'varchar' then '""'
        when row.data_type = 'bool' then 'false'
        when row.data_type = 'boolean' then 'false'
        when row.data_type = 'integer' then '0'
        else '""'
      end;
    end if;
    
    -- field
    if (row.is_nullable = 'YES') then
      result := result || '  ' || tp || ' _'  || name || ';' || cr;
    else
      result := result || '  ' || tp || ' _'  || name || ' = ' || dv || ';' || cr;
    end if;
    -- getter
    result := result || '  ' || tp || ' get ' || name || ' {' || cr;
    result := result || '  ' || '  return _' || name || ';'  || cr;
    result := result || '  }' || cr || cr;
    -- setter
    result := result || '  ' || 'set ' || name || '(' || tp || ' value) {' || cr;
    result := result || '    if (value != ' || name || ') {' || cr;
    result := result || '      _' || name || ' = value;' || cr;
    result := result || '      notifyListeners();' || cr;
    result := result || '    }' || cr;
    result := result || '  }' || cr || cr;
  end loop;

  -- toMap
  result := result || '  @override
  Map<String, dynamic> toMap() {
    var result = <String, dynamic>{};' || cr;
  for row in  
  (
    select c.*
      from information_schema.tables t
      join information_schema.columns c 
        on t.table_name = c.table_name
     where t.table_name = dart_generate_class.table_name
     order by c.ordinal_position
  )
  loop
    name := row.column_name;
    result := result || '    result["' || name || '"] = _' || name || ';' || cr;
  end loop;
    
  result := result || '
    return result;
  }' || cr || cr;

  -- fromMap
  result := result || '  @override
  void fromMap(Map<String, dynamic> map) {' || cr;
  for row in  
  (
    select c.*
      from information_schema.tables t
      join information_schema.columns c 
        on t.table_name = c.table_name
     where t.table_name = dart_generate_class.table_name
     order by c.ordinal_position
  )
  loop
    name := row.column_name;
    result := result || '    _' || name || ' = map["' || name || '"];' || cr;
  end loop;
  
  result := result || '
  }' || cr;
  
  result := result || '}' || cr;
  return result;
end;
$$;

/* select dart_generate_class('fhir_types') */

create or replace function dart_generator() 
returns text
language plpgsql
as
$$
declare
  result text  := '';
  row    record;
  cr     text  := chr(10);
begin
  perform set_config('response.headers', json_build_array(json_build_object('Content-Type', 'text/plain'))::text, true);

  result := result || 'import "fe_document.dart";' || cr;
  result := result || 'import "package:flutter/widgets.dart";' || cr || cr;  

  for row in 
  (
    select t.table_name
      from information_schema.tables t
     where t.table_schema = 'public'
       and t.table_name not in ('__EFMigrationsHistory', 'fhir_artifacts')
     order by 1
  )
  loop
    result := result || dart_generate_class(row.table_name) || cr || cr;
  end loop;
  return result;
end 
$$;

/* select dart_generator() */

grant execute on function dart_generator to anonymous;

