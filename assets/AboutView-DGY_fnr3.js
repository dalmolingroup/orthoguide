import{_ as a,c as e,a as o,o as d}from"./index-DI0B2m_I.js";const r={},n={class:"about"};function s(i,t){return d(),e("div",n,t[0]||(t[0]=[o(`<div class="text-section" data-v-7b107716><h3 data-v-7b107716>About OrthoGuide</h3><p data-v-7b107716> OrthoGuide provides immediate access to high-quality, pre-computed rooting data for over 300 eukaryotic species. Instead of running complex analyses, users can query our database and get the information they need in seconds, along with a few exploratory plots. </p><p data-v-7b107716> All data in our database is generated using the <a href="https://github.com/sysbiolab/GeneBridge" target="_blank" rel="noopener noreferrer" data-v-7b107716>GeneBridge R package (v0.99.2)</a>, a method that infers a gene&#39;s evolutionary root based on the distribution of its orthologs. The gene-to-cog information was obtained from <a href="https://version-11-0b.string-db.org/cgi/download" target="_blank" rel="noopener noreferrer" data-v-7b107716>STRING-db version 11.0</a>. </p></div><div class="text-section" data-v-7b107716><h3 data-v-7b107716>How it Works</h3><p data-v-7b107716> When you query a gene set for a selected species, OrthoGuide identifies the <strong data-v-7b107716>Cluster of Orthologous Groups (COG)</strong> for each gene in the database. A COG represents a group of orthologs found across many different species. </p><p data-v-7b107716> The evolutionary root (the Last Common Ancestor where the gene first appeared) for each COG was pre-computed using the <strong data-v-7b107716>Bridge algorithm</strong>. This algorithm analyzes the presence and absence of the COG across the <em data-v-7b107716>entire eukaryotic phylogenetic tree</em>. </p></div><div class="text-section" data-v-7b107716><h3 data-v-7b107716>Citation</h3><p data-v-7b107716> If you use data from OrthoGuide in your research, please cite the foundational paper for the Bridge algorithm: </p><p data-v-7b107716> Campos, L. R. S., Trefflich, S., Morais, D. A. A., Imparato, D. O., Chagas, V. S., Albanus, R. D., Dalmolin, R. J. S., &amp; Castro, M. A. A. (2024). Bridge: A New Algorithm for Rooting Orthologous Genes in Large-Scale Evolutionary Analyses. Molecular Biology and Evolution, 41(2), msae019. <a href="https://doi.org/10.1093/molbev/msae019" target="_blank" data-v-7b107716>10.1093/molbev/msae019</a></p><h3 data-v-7b107716>Database</h3><div class="buttons-div" data-v-7b107716><a href="https://github.com/jvfe/orthoguide/raw/refs/heads/main/orthoguide_front/public/orthoguide_data.db.gz" class="download-button" target="_blank" rel="noopener noreferrer" data-v-7b107716> Download Database </a></div></div><div class="documentation-section" data-v-7b107716><h3 data-v-7b107716>Database Schema</h3><div class="table-container" data-v-7b107716><table class="schema-table" data-v-7b107716><thead data-v-7b107716><tr data-v-7b107716><th data-v-7b107716>Column</th><th data-v-7b107716>Data Type</th><th data-v-7b107716>Description</th></tr></thead><tbody data-v-7b107716><tr data-v-7b107716><td data-v-7b107716>cog_id</td><td data-v-7b107716>TEXT</td><td data-v-7b107716>The Cluster of Orthologous Groups (COG) identifier.</td></tr><tr data-v-7b107716><td data-v-7b107716>root</td><td data-v-7b107716>INTEGER</td><td data-v-7b107716>The numerical ID representing the last common ancestor (LCA) or root clade.</td></tr><tr data-v-7b107716><td data-v-7b107716>clade_name</td><td data-v-7b107716>TEXT</td><td data-v-7b107716>The descriptive name of the root clade.</td></tr><tr data-v-7b107716><td data-v-7b107716>protein_id</td><td data-v-7b107716>TEXT</td><td data-v-7b107716>The STRING protein identifier for the specific protein.</td></tr><tr data-v-7b107716><td data-v-7b107716>preferred_name</td><td data-v-7b107716>TEXT</td><td data-v-7b107716>The common gene name (e.g., HGNC symbol) used for querying.</td></tr></tbody></table></div></div><div class="documentation-section" data-v-7b107716><h3 data-v-7b107716>Using the Database</h3><p data-v-7b107716> The OrthoGuide database is provided as a compressed SQLite file (<code data-v-7b107716>.db.gz</code>). <strong data-v-7b107716>You must decompress it first before using it.</strong> This allows for efficient querying without loading the entire dataset into memory. Below are examples of how to interact with the database using R and Python. </p><div class="code-examples" data-v-7b107716><div class="code-block" data-v-7b107716><h4 data-v-7b107716>R</h4><pre data-v-7b107716><code data-v-7b107716>library(RSQLite)
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
dbDisconnect(con)</code></pre></div><div class="code-block" data-v-7b107716><h4 data-v-7b107716>Python</h4><pre data-v-7b107716><code data-v-7b107716>import sqlite3
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
con.close()</code></pre></div></div></div>`,5)]))}const c=a(r,[["render",s],["__scopeId","data-v-7b107716"]]);export{c as default};
