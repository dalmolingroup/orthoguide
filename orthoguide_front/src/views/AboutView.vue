<template>
  <div class="about">
    <div class="text-section">
      <h3>About OrthoGuide</h3>
      <p>
        OrthoGuide provides immediate access to high-quality, pre-computed rooting data for over 300
        eukaryotic species. Instead of running complex analyses, users can query our database and
        get the information they need in seconds, along with a few exploratory plots.
      </p>
      <p>
        All data in our database is generated using the
        <a href="https://github.com/sysbiolab/GeneBridge" target="_blank" rel="noopener noreferrer"
          >GeneBridge R package (v0.99.2)</a
        >, a method that infers a gene's evolutionary root based on the distribution of its
        orthologs. The gene-to-cog information was obtained from
        <a
          href="https://version-11-0b.string-db.org/cgi/download"
          target="_blank"
          rel="noopener noreferrer"
          >STRING-db version 11.0</a
        >.
      </p>
    </div>
    <div class="text-section">
      <h3>How it Works</h3>
      <p>
        When you query a gene set for a selected species, OrthoGuide identifies the
        <strong>Cluster of Orthologous Groups (COG)</strong> for each gene in the database. A COG
        represents a group of orthologs found across many different species.
      </p>
      <p>
        The evolutionary root (the Last Common Ancestor where the gene first appeared) for each COG
        was pre-computed using the <strong>Bridge algorithm</strong>. This algorithm analyzes the
        presence and absence of the COG across the <em>entire eukaryotic phylogenetic tree</em>.
      </p>
    </div>
    <div class="text-section">
      <h3>Citation</h3>
      <p>
        If you use data from OrthoGuide in your research, please cite the foundational paper for the
        Bridge algorithm:
      </p>
      <p>
        Campos, L. R. S., Trefflich, S., Morais, D. A. A., Imparato, D. O., Chagas, V. S., Albanus,
        R. D., Dalmolin, R. J. S., & Castro, M. A. A. (2024). Bridge: A New Algorithm for Rooting
        Orthologous Genes in Large-Scale Evolutionary Analyses. Molecular Biology and Evolution,
        41(2), msae019.
        <a href="https://doi.org/10.1093/molbev/msae019" target="_blank">10.1093/molbev/msae019</a>
      </p>
      <h3>Database</h3>
      <div class="buttons-div">
        <a
          href="https://github.com/jvfe/orthoguide/raw/refs/heads/main/orthoguide_front/public/orthoguide_data.db"
          class="download-button"
          target="_blank"
          rel="noopener noreferrer"
        >
          Download Database
        </a>
        <a
          href="https://github.com/jvfe/orthoguide/raw/refs/heads/main/db_creation/results/orthoguide_database.schema.csv"
          class="download-button"
          target="_blank"
          rel="noopener noreferrer"
        >
          Download Schema
        </a>
      </div>
    </div>
    <div class="documentation-section">
      <h3>Database Schema</h3>
      <div class="table-container">
        <table class="schema-table">
          <thead>
            <tr>
              <th>Column</th>
              <th>Data Type</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>cog_id</td>
              <td>TEXT</td>
              <td>The Cluster of Orthologous Groups (COG) identifier.</td>
            </tr>
            <tr>
              <td>root</td>
              <td>INTEGER</td>
              <td>The numerical ID representing the last common ancestor (LCA) or root clade.</td>
            </tr>
            <tr>
              <td>clade_name</td>
              <td>TEXT</td>
              <td>The descriptive name of the root clade.</td>
            </tr>
            <tr>
              <td>protein_id</td>
              <td>TEXT</td>
              <td>The STRING protein identifier for the specific protein.</td>
            </tr>
            <tr>
              <td>preferred_name</td>
              <td>TEXT</td>
              <td>The common gene name (e.g., HGNC symbol) used for querying.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div class="documentation-section">
      <h3>Using the Database</h3>
      <p>
        The OrthoGuide database is provided as a SQLite file, which allows for efficient querying
        without loading the entire dataset into memory. Below are examples of how to interact with
        the database using R and Python.
      </p>
      <div class="code-examples">
        <div class="code-block">
          <h4>R</h4>
          <pre><code>library(RSQLite)
library(dplyr)

# Connect to the database
con &lt;- dbConnect(SQLite(), "orthoguide_data.db")

# List tables
dbListTables(con)

# Query the data
# (Assuming 'orthoguide' is the table name)
data &lt;- tbl(con, "orthoguide") %&gt;%
  head(10) %&gt;%
  collect()

# Disconnect
dbDisconnect(con)</code></pre>
        </div>
        <div class="code-block">
          <h4>Python</h4>
          <pre><code>import sqlite3
import pandas as pd

# Connect to the database
con = sqlite3.connect("orthoguide_data.db")

# List tables
cursor = con.cursor()
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
print(cursor.fetchall())

# Query the data
df = pd.read_sql_query("SELECT * FROM orthoguide LIMIT 10", con)

# Close connection
con.close()</code></pre>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.about {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-start; /* Alinha os itens ao topo */
  justify-content: space-between;
  background-color: var(--color-background);
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid var(--color-border);
}

.about > div {
  margin: 0 1em;
  width: 45%;
}

p {
  font-size: 12px;
  line-height: 1.6; /* Melhora a legibilidade */
}

.text-section > p {
  margin: 1em 0;
}

.buttons-div {
  display: flex;
  justify-content: space-evenly;
}

.download-button {
  display: inline-block;
  margin-top: 1.5em;
  background-color: var(--color-background-soft);
  color: var(--color-text);
  border: 1px solid var(--color-border);
  padding: 10px 18px;
  border-radius: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  text-decoration: none;
  cursor: pointer;
  transition:
    background-color 0.2s,
    border-color 0.2s;
}

.download-button:hover {
  background-color: var(--color-background-mute);
  border-color: var(--color-border-hover);
}

.about > .documentation-section {
  width: 100%;
  margin-top: 2em;
}

.code-examples {
  display: flex;
  gap: 20px;
  margin-top: 1em;
}

.code-block {
  flex: 1;
  background-color: var(--color-background-soft);
  padding: 15px;
  border-radius: 8px;
  border: 1px solid var(--color-border);
  overflow-x: auto;
}

pre {
  margin: 0;
  font-family: monospace;
  font-size: 0.9em;
  white-space: pre-wrap;
}

.table-container {
  overflow-x: auto;
  margin-top: 1em;
}

.schema-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9em;
}

.schema-table th,
.schema-table td {
  border: 1px solid var(--color-border);
  padding: 8px;
  text-align: left;
}

.schema-table th {
  background-color: var(--color-background-soft);
  font-weight: 600;
}

@media (max-width: 768px) {
  .about {
    flex-direction: column;
    padding: 20px;
  }

  .about > div {
    width: 100%;
    margin: 0 0 2em 0;
  }

  .about > div:last-child {
    margin-bottom: 0;
  }

  .buttons-div {
    flex-direction: column;
  }

  .download-button {
    text-align: center;
  }

  .code-examples {
    flex-direction: column;
  }
}
</style>
