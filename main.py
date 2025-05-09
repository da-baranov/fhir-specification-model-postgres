import os
import urllib.request
import zipfile
import psycopg2
from dotenv import load_dotenv, dotenv_values 
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
    
       
def download():
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
        # "extension-definitions.xml",
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
                cur.execute("insert into fhir.artifacts(release,filename,file) values(%s,%s,%s) on conflict (release,filename) do update set file=%s",
                    (dirname, filename, data, data))
                conn.commit()
                print("File '" + path + "' uploaded to the database")


def main():
    load_dotenv() 
    download()
    upload_artifacts()
    
main()