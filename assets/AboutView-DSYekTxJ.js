import{_ as t,c as a,a as o,o as d}from"./index-aiSoUDRd.js";const r={},n={class:"about"};function s(i,e){return d(),a("div",n,e[0]||(e[0]=[o(`<div class="text-section" data-v-e4949349><h3 data-v-e4949349>About OrthoGuide</h3><p data-v-e4949349> OrthoGuide provides immediate access to high-quality, pre-computed rooting data for over 300 eukaryotic species. Instead of running complex analyses, users can query our database and get the information they need in seconds, along with a few exploratory plots. </p><p data-v-e4949349> All data in our database is generated using the <a href="https://github.com/sysbiolab/GeneBridge" target="_blank" rel="noopener noreferrer" data-v-e4949349>GeneBridge R package (v0.99.2)</a>, a method that infers a gene&#39;s evolutionary root based on the distribution of its orthologs. The gene-to-cog information was obtained from <a href="https://version-11-0b.string-db.org/cgi/download" target="_blank" rel="noopener noreferrer" data-v-e4949349>STRING-db version 11.0</a>. </p></div><div class="text-section" data-v-e4949349><h3 data-v-e4949349>How it Works</h3><p data-v-e4949349> When you query a gene set for a selected species, OrthoGuide identifies the <strong data-v-e4949349>Cluster of Orthologous Groups (COG)</strong> for each gene in the database. A COG represents a group of orthologs found across many different species. </p><p data-v-e4949349> The evolutionary root (the Last Common Ancestor where the gene first appeared) for each COG was pre-computed using the <strong data-v-e4949349>Bridge algorithm</strong>. This algorithm analyzes the presence and absence of the COG across the <em data-v-e4949349>entire eukaryotic phylogenetic tree</em>. </p></div><div class="text-section" data-v-e4949349><h3 data-v-e4949349>Citation</h3><p data-v-e4949349> If you use data from OrthoGuide in your research, please cite our paper: </p><p data-v-e4949349> Cavalcante, J. V. F., de Azevedo, G. M., Imparato, D. O., Marques-Coelho, D., Castro, M. A. A., &amp; Dalmolin, R. J. S. (2026). OrthoGuide: A Database for Rooting Inference of Orthologous Genes. Genome Biology and Evolution, 18(6). <a href="https://doi.org/10.1093/gbe/evag119" target="_blank" data-v-e4949349>10.1093/gbe/evag119</a></p><h3 data-v-e4949349>Database</h3><div class="buttons-div" data-v-e4949349><a href="https://github.com/jvfe/orthoguide/raw/refs/heads/main/orthoguide_front/public/orthoguide_data.db.gz" class="download-button" target="_blank" rel="noopener noreferrer" data-v-e4949349> Download Database </a></div></div><div class="documentation-section" data-v-e4949349><h3 data-v-e4949349>Database Schema</h3><div class="table-container" data-v-e4949349><table class="schema-table" data-v-e4949349><thead data-v-e4949349><tr data-v-e4949349><th data-v-e4949349>Column</th><th data-v-e4949349>Data Type</th><th data-v-e4949349>Description</th></tr></thead><tbody data-v-e4949349><tr data-v-e4949349><td data-v-e4949349>cog_id</td><td data-v-e4949349>TEXT</td><td data-v-e4949349>The Cluster of Orthologous Groups (COG) identifier.</td></tr><tr data-v-e4949349><td data-v-e4949349>root</td><td data-v-e4949349>INTEGER</td><td data-v-e4949349>The numerical ID representing the last common ancestor (LCA) or root clade.</td></tr><tr data-v-e4949349><td data-v-e4949349>clade_name</td><td data-v-e4949349>TEXT</td><td data-v-e4949349>The descriptive name of the root clade.</td></tr><tr data-v-e4949349><td data-v-e4949349>protein_id</td><td data-v-e4949349>TEXT</td><td data-v-e4949349>The STRING protein identifier for the specific protein.</td></tr><tr data-v-e4949349><td data-v-e4949349>preferred_name</td><td data-v-e4949349>TEXT</td><td data-v-e4949349>The common gene name (e.g., HGNC symbol) used for querying.</td></tr></tbody></table></div></div><div class="documentation-section" data-v-e4949349><h3 data-v-e4949349>Using the Database</h3><p data-v-e4949349> The OrthoGuide database is provided as a compressed SQLite file (<code data-v-e4949349>.db.gz</code>). <strong data-v-e4949349>You must decompress it first before using it.</strong> This allows for efficient querying without loading the entire dataset into memory. Below are examples of how to interact with the database using R and Python. </p><div class="code-examples" data-v-e4949349><div class="code-block" data-v-e4949349><h4 data-v-e4949349>R</h4><pre data-v-e4949349><code data-v-e4949349>library(RSQLite)
library(dplyr)

# Connect to the database
con &lt;- dbConnect(SQLite(), &quot;orthoguide_data.db&quot;)

# List tables
dbListTables(con)

# Query the data
data &lt;- tbl(con, &quot;9606&quot;) %&gt;%
  head(10) %&gt;%
  collect()

# Disconnect
dbDisconnect(con)</code></pre></div><div class="code-block" data-v-e4949349><h4 data-v-e4949349>Python</h4><pre data-v-e4949349><code data-v-e4949349>import sqlite3
import pandas as pd

# Connect to the database
con = sqlite3.connect(&quot;orthoguide_data.db&quot;)

# List tables
cursor = con.cursor()
cursor.execute(&quot;SELECT name FROM sqlite_master WHERE type=&#39;table&#39;;&quot;)
print(cursor.fetchall())

# Query the data
df = pd.read_sql_query(&#39;SELECT * FROM &quot;9606&quot; LIMIT 10&#39;, con)

# Close connection
con.close()</code></pre></div></div></div>`,5)]))}const h=t(r,[["render",s],["__scopeId","data-v-e4949349"]]);export{h as default};
