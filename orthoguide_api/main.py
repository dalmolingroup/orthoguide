from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from typing import List, Optional
import sqlite3
import os

DB_PATH = "data/test_data.db"
ALLOWED_ORGANISMS = ["hsa"]
DEFAULT_TABLE_NAME = "hsa"

# This function creates and populates the database if it doesn't exist.
# It's useful for ensuring the app is runnable out-of-the-box.
def setup_database():
    """Creates and populates a dummy SQLite database if it doesn't already exist."""
    if not os.path.exists(DB_PATH):
        print(f"Database not found. Creating a new one at '{DB_PATH}'...")
        try:
            con = sqlite3.connect(DB_PATH)
            cur = con.cursor()

            # Create the table
            cur.execute(f'''
                CREATE TABLE {DEFAULT_TABLE_NAME} (
                    node TEXT,
                    cog_id TEXT,
                    root REAL,
                    clade_name TEXT,
                    queryItem TEXT PRIMARY KEY,
                    ncbiTaxonId REAL
                )
            ''')

            # Dummy data
            dummy_data = [
                ("ENSP00000265371", "NOG06579", 23.00, "Ambulacraria", "NRP1", 9606.00),
                ("ENSP00000265562", "KOG2220", 36.00, "SAR", "PTPN23", 9606.00),
                ("ENSP00000265734", "KOG0594", 37.00, "Metamonada", "CDK6", 9606.00),
                ("ENSP00000267082", "KOG1226", 30.00, "Choanoflagellata", "ITGB7", 9606.00),
                ("ENSP00000268603", "KOG3594", 30.00, "Choanoflagellata", "CDH11", 9606.00)
            ]

            # Insert dummy data
            cur.executemany(f'INSERT INTO {DEFAULT_TABLE_NAME} VALUES (?,?,?,?,?,?)', dummy_data)
            
            con.commit()
            print("Dummy database 'test_data.db' created successfully.")
        except sqlite3.Error as e:
            print(f"Database error: {e}")
        finally:
            if con:
                con.close()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """On startup, check for and set up the database."""
    setup_database()
    yield
    
app = FastAPI(
    title="OrthoGuide API",
    description="An API to get rooting results from GeneBridge.",
    lifespan=lifespan
)

origins = [
    "http://localhost:8080",
    "http://localhost:5173",
    "http://localhost",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db_connection():
    """Establishes and returns a connection to the SQLite database."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

@app.get("/get_roots", summary="Get roots for a specific set of genes in a reference species")
async def get_roots(
    genes: Optional[str] = Query(None, description="A comma-separated string of gene names."),
    species: Optional[str] = Query(None, description="A string with a species code (e.g. 'hsa' for human)")
):
    """
    Retrieves rooting information from the database based on a provided list of gene names.
    """
    if not genes:
        raise HTTPException(
            status_code=400, 
            detail="Please provide a comma-separated list of genes in the 'genes' parameter and a species code in the 'species' parameter."
        )

    if species not in ALLOWED_ORGANISMS:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid species code. Allowed values are: {', '.join(ALLOWED_ORGANISMS)}"
        )

    gene_list = [gene.strip() for gene in genes.split(',')]
    
    # Using '?' as placeholders prevents SQL inject
    placeholders = ','.join(['?'] * len(gene_list))

    sql_query = f"SELECT * FROM {species} WHERE queryItem IN ({placeholders})"

    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(sql_query, gene_list)
        result = cursor.fetchall()
        
        # Convert list of Row objects to list of dicts for JSON serialization
        return [dict(row) for row in result]
        
    except sqlite3.Error as e:
        raise HTTPException(
            status_code=500, 
            detail=f"Database query failed: {e}"
        )
    finally:
        if conn:
            conn.close()

@app.get("/", summary="API Welcome Message")
def read_root():
    """Provides a welcome message for the API root."""
    return {"message": "Welcome to the OrthoGuide API! Use the /get_root endpoint to get data."}
