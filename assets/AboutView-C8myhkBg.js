import{_ as a,c as e,a as c,o}from"./index-C9EovyWX.js";const d={},r={class:"about"};function n(s,t){return o(),e("div",r,t[0]||(t[0]=[c(`<div class="text-section" data-v-cc0531c8><h3 data-v-cc0531c8>About OrthoGuide</h3><p data-v-cc0531c8> OrthoGuide provides immediate access to high-quality, pre-computed rooting data for over 300 eukaryotic species. Instead of running complex analyses, users can query our database and get the information they need in seconds, along with a few exploratory plots. </p><p data-v-cc0531c8> All data in our database is generated using the <a href="https://github.com/sysbiolab/GeneBridge" target="_blank" rel="noopener noreferrer" data-v-cc0531c8>GeneBridge R package (v0.99.2)</a>, a method that infers a gene&#39;s evolutionary root based on the distribution of its orthologs. The gene-to-cog information was obtained from <a href="https://version-11-0b.string-db.org/cgi/download" target="_blank" rel="noopener noreferrer" data-v-cc0531c8>STRING-db version 11.0</a>. </p></div><div class="text-section" data-v-cc0531c8><h3 data-v-cc0531c8>How it Works</h3><p data-v-cc0531c8> When you query a gene set for a selected species, OrthoGuide identifies the <strong data-v-cc0531c8>Cluster of Orthologous Groups (COG)</strong> for each gene in the database. A COG represents a group of orthologs found across many different species. </p><p data-v-cc0531c8> The evolutionary root (the Last Common Ancestor where the gene first appeared) for each COG was pre-computed using the <strong data-v-cc0531c8>Bridge algorithm</strong>. This algorithm analyzes the presence and absence of the COG across the <em data-v-cc0531c8>entire eukaryotic phylogenetic tree</em>. </p></div><div class="text-section" data-v-cc0531c8><h3 data-v-cc0531c8>Citation</h3><p data-v-cc0531c8> If you use data from OrthoGuide in your research, please cite the foundational paper for the Bridge algorithm: </p><p data-v-cc0531c8> Campos, L. R. S., Trefflich, S., Morais, D. A. A., Imparato, D. O., Chagas, V. S., Albanus, R. D., Dalmolin, R. J. S., &amp; Castro, M. A. A. (2024). Bridge: A New Algorithm for Rooting Orthologous Genes in Large-Scale Evolutionary Analyses. Molecular Biology and Evolution, 41(2), msae019. <a href="https://doi.org/10.1093/molbev/msae019" target="_blank" data-v-cc0531c8>10.1093/molbev/msae019</a></p><h3 data-v-cc0531c8>Database</h3><div class="buttons-div" data-v-cc0531c8><a href="https://github.com/jvfe/orthoguide/raw/refs/heads/main/orthoguide_front/public/orthoguide_data.db.gz" class="download-button" target="_blank" rel="noopener noreferrer" data-v-cc0531c8> Download Database </a></div></div><div class="documentation-section" data-v-cc0531c8><h3 data-v-cc0531c8>Database Schema</h3><div class="table-container" data-v-cc0531c8><table class="schema-table" data-v-cc0531c8><thead data-v-cc0531c8><tr data-v-cc0531c8><th data-v-cc0531c8>Column</th><th data-v-cc0531c8>Data Type</th><th data-v-cc0531c8>Description</th></tr></thead><tbody data-v-cc0531c8><tr data-v-cc0531c8><td data-v-cc0531c8>cog_id</td><td data-v-cc0531c8>TEXT</td><td data-v-cc0531c8>The Cluster of Orthologous Groups (COG) identifier.</td></tr><tr data-v-cc0531c8><td data-v-cc0531c8>root</td><td data-v-cc0531c8>INTEGER</td><td data-v-cc0531c8>The numerical ID representing the last common ancestor (LCA) or root clade.</td></tr><tr data-v-cc0531c8><td data-v-cc0531c8>clade_name</td><td data-v-cc0531c8>TEXT</td><td data-v-cc0531c8>The descriptive name of the root clade.</td></tr><tr data-v-cc0531c8><td data-v-cc0531c8>protein_id</td><td data-v-cc0531c8>TEXT</td><td data-v-cc0531c8>The STRING protein identifier for the specific protein.</td></tr><tr data-v-cc0531c8><td data-v-cc0531c8>preferred_name</td><td data-v-cc0531c8>TEXT</td><td data-v-cc0531c8>The common gene name (e.g., HGNC symbol) used for querying.</td></tr></tbody></table></div></div><div class="documentation-section" data-v-cc0531c8><h3 data-v-cc0531c8>Using the Database</h3><p data-v-cc0531c8> The OrthoGuide database is provided as a compressed SQLite file (<code data-v-cc0531c8>.db.gz</code>). <strong data-v-cc0531c8>You must decompress it first before using it.</strong> This allows for efficient querying without loading the entire dataset into memory. Below are examples of how to interact with the database using R and Python. </p><div class="code-examples" data-v-cc0531c8><div class="code-block" data-v-cc0531c8><h4 data-v-cc0531c8>R</h4><pre data-v-cc0531c8><code data-v-cc0531c8>library(RSQLite)
library(dplyr)

# Connect to the database
con &lt;- dbConnect(SQLite(), &quot;orthoguide_data.db&quot;)

# List tables
dbListTables(con)

# Query the data
# (Assuming &#39;orthoguide&#39; is the table name)
data &lt;- tbl(con, &quot;orthoguide&quot;) %&gt;%
  head(10) %&gt;%
  collect()

# Disconnect
dbDisconnect(con)</code></pre></div><div class="code-block" data-v-cc0531c8><h4 data-v-cc0531c8>Python</h4><pre data-v-cc0531c8><code data-v-cc0531c8>import sqlite3
import pandas as pd

# Connect to the database
con = sqlite3.connect(&quot;orthoguide_data.db&quot;)

# List tables
cursor = con.cursor()
cursor.execute(&quot;SELECT name FROM sqlite_master WHERE type=&#39;table&#39;;&quot;)
print(cursor.fetchall())

# Query the data
df = pd.read_sql_query(&quot;SELECT * FROM orthoguide LIMIT 10&quot;, con)

# Close connection
con.close()</code></pre></div></div></div>`,5)]))}const h=a(d,[["render",n],["__scopeId","data-v-cc0531c8"]]);export{h as default};
