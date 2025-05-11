from dotenv import load_dotenv
import io
import os
import psycopg2
import urllib.request
import zipfile

releases = [
    # "STU3", 
    "R4", 
    "R4B",
    "R5"
]

def get_db_schema() -> str:
    schema = os.getenv("SCHEMA")
    if (not schema):
        schema = "public"
    return schema
       
def db_connect():
    try:
        cs = os.getenv("CONNECTION_STRING")
        conn = psycopg2.connect(cs)
        print("Connected to Postgres")
        return conn
    except:
        print("Unable to connect to the database")
        raise 
    
       
def download_artifacts():
    for release in releases:
        url      = "https://www.hl7.org/fhir/" + release + "/definitions.xml.zip"
        filename = "assets/" + release + "/definitions.xml.zip"
        dirname  = "assets/" + release
        urllib.request.urlretrieve(url, filename)
        print("FHIR " + release + " assets download complete")
        with zipfile.ZipFile(filename, 'r') as file:
            file.extractall(dirname)
        print("FHIR " + release + " XML assets unpacked")
    
    
def upload_artifacts():
    files = [
        "conceptmaps.xml",
        "dataelements.xml",
        "profiles-others.xml",
        "profiles-resources.xml",
        "profiles-types.xml",
        "search-parameters.xml"
    ]
    schema = get_db_schema()
    conn = db_connect()
    cur = conn.cursor()
    for dirname in releases:
        for filename in files:
            if dirname == "R4B":
                path = "assets/" + dirname + "/definitions.xml/" + filename
            else:
                path = "assets/" + dirname + "/" + filename
            with io.open(path,'r',encoding='utf8') as f:
                data = f.read()
                cur.execute("insert into " + schema + ".fhir_artifacts(release,filename,file) " \
                               " values(%s,%s,%s) " \
                               " on conflict (release,filename) " \
                               " do update set file=%s",
                    (dirname, filename, data, data))
                conn.commit()
                print("File '" + path + "' uploaded to the database")

def exec_script(conn, path):
    schema = get_db_schema()
    with io.open(path,'r',encoding='utf8') as f:
        script = f.read()
        script = script.replace("create schema if not exists fhir", "create schema if not exists " + schema)
        script = script.replace(" public.", " " + schema + ".")

        cur = conn.cursor()
        cur.execute(script)
        conn.commit()
    print("SQL script '" + path + "' exec success")

def create_schema():
    conn = db_connect()
    exec_script(conn, "sql/Scripts/fhir/0000_s_fhir_schema.sql")
    exec_script(conn, "sql/Scripts/fhir/0005_t_fhir_releases.sql")
    exec_script(conn, "sql/Scripts/fhir/0010_t_fhir_artifacts.sql")

def create_tables():
    conn = db_connect()
    exec_script(conn, "sql/Scripts/fhir/0020_t_fhir_types.sql")
    exec_script(conn, "sql/Scripts/fhir/0030_t_fhir_elements.sql")    
    exec_script(conn, "sql/Scripts/fhir/0040_t_fhir_element_types.sql") 
    exec_script(conn, "sql/Scripts/fhir/0050_t_fhir_search_params.sql")
    exec_script(conn, "sql/Scripts/fhir/0060_t_fhir_search_param_target_types.sql")
    exec_script(conn, "sql/Scripts/fhir/0070_t_fhir_interactions.sql")
    exec_script(conn, "sql/Scripts/fhir/0080_t_fhir_operations.sql")
    exec_script(conn, "sql/Scripts/fhir/0090_t_fhir_operation_params.sql")

def main():
    load_dotenv() 
    create_schema()
    download_artifacts()
    upload_artifacts()
    create_tables()
    
main()