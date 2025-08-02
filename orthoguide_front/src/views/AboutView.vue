<template>
  <div class="about">
    <div class="text-section">
      <h3>About OrthoGuide</h3>
      <p>
        OrthoGuide provides immediate access to high-quality, pre-computed rooting data for 6
        species. Instead of running complex analyses, users can query our database and get the
        information they need in seconds, along with a few exploratory plots.
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
  </div>
</template>

<style scoped>
.about {
  display: flex;
  align-items: flex-start; /* Alinha os itens ao topo */
  justify-content: space-between;
  background-color: white;
  padding: 40px;
  border-radius: 16px;
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.05);
  border: 1px solid #e9ecef;
}

.about > div {
  margin: 0 1em;
  width: 50%;
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
  background-color: #f9fafb;
  color: #374151;
  border: 1px solid #d1d5db;
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
  background-color: #f3f4f6;
  border-color: #9ca3af;
}
</style>
