import os
import urllib.request
import zipfile
import psycopg2
from dotenv import load_dotenv
import io

releases = [
    # "STU3", 
    "R4", 
    "R4B",
    "R5"
]
       
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
                cur.execute("insert into fhir.artifacts(release,filename,file) " \
                               " values(%s,%s,%s) " \
                               " on conflict (release,filename) " \
                               " do update set file=%s",
                    (dirname, filename, data, data))
                conn.commit()
                print("File '" + path + "' uploaded to the database")

def exec_script(conn, path):
    with io.open(path,'r',encoding='utf8') as f:
        script = f.read()
        cur = conn.cursor()
        cur.execute(script)
        conn.commit()
    print("SQL script '" + path + "' exec success")

def create_schema():
    conn = db_connect()
    exec_script(conn, "sql/Scripts/fhir/schemas/s_schema.sql")
    exec_script(conn, "sql/Scripts/fhir/tables/t_artifacts.sql")

def exec_scripts():
    conn = db_connect()
    
    exec_script(conn, "sql/Scripts/fhir/views/v_simple_types.sql")
    exec_script(conn, "sql/Scripts/fhir/views/v_resources.sql")

    exec_script(conn, "sql/Scripts/fhir/functions/f_element_belongs_to.sql")
    exec_script(conn, "sql/Scripts/fhir/functions/f_extract_types.sql")
    exec_script(conn, "sql/Scripts/fhir/functions/f_get_root_name.sql")
    exec_script(conn, "sql/Scripts/fhir/functions/f_get_short_name.sql")
    exec_script(conn, "sql/Scripts/fhir/functions/f_resolve_type.sql")

    exec_script(conn, "sql/Scripts/fhir/views/v_elements.sql")
    exec_script(conn, "sql/Scripts/fhir/views/v_backbones.sql")

def main():
    load_dotenv() 
    download_artifacts()
    create_schema()
    upload_artifacts()
    exec_scripts()
    
main()